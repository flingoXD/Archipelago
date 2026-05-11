extends CharacterBody2D
class_name Enemy

@export var enemy_id: String
var hp
@export var max_hp = 10
@export var atk = 0
@export var def = 0
var inv = 0
@export var dropped_gold = 0
@export var dropped_xp = 0
@export var death_tex: Texture2D
@export var respawn_after_spare = false
@export var gauntlet_fade = false
@export var knockback = 200
@export var detection: Area2D

var target:
    set(val):
        if target is Player:
            target.fighting.remove_at(target.fighting.find(self))
        if val is Player:
            val.fighting.append(self)
        target = val
var no_ai = 0
var detect_time = 0
var spare_time
var talkable = true

var selected = false:
    set(val):
        selected = val
        if spare_time:
            return
        elif selected:
            self.material = select_shader
        else:
            self.material = null

var hurt_sfx = preload("res://sounds/hurt.wav")
var vaporise_sfx = preload("res://sounds/vaporise.wav")
var detect_sfx = preload("res://sounds/detect.wav")
var numbers_scene = preload("res://objects/numbers.tscn")
var detect_scene = preload("res://objects/detect.tscn")
var select_shader = preload("res://objects/select.tres")
var gold_scene = preload("res://objects/gold.tscn")
var xp_scene = preload("res://objects/xp.tscn")
var spare_shader = preload("res://objects/spare.tres")
var pink_spare_shader = preload("res://objects/spare_but_pink.tres")
var spare_sfx = preload("res://sounds/spare.wav")
var spare_star_scene = preload("res://objects/spare_star.tscn")
var textbox_sfx = preload("res://sounds/talk_textbox.wav")
var hit_particle_scene = preload("res://objects/hit_particles.tscn")
var flee_sfx = preload("res://sounds/flee.wav")

signal death
signal spared

func _ready():
    collision_layer = 2
    hp = max_hp
    if enemy_id:
        var killed = Globals.get_enemy_flag(enemy_id)
        if killed or killed == false and not respawn_after_spare:
            self.queue_free()

func play_sound(stream):
    var playback = AudioStreamPlayer.new()
    playback.stream = stream
    playback.connect("finished", func():
        playback.queue_free()
    )
    self.get_parent().add_child(playback)
    playback.play()

func damage(player_atk, left = false):
    if inv > 0 or not self.visible:
        return
    var dmg = hp + randi_range(0, 20) if spare_time else roundi((player_atk - def) * randf_range(1, 2))
    hp -= dmg
    play_sound(hurt_sfx)
    inv = 0.1
    var hit_particles = hit_particle_scene.instantiate()
    hit_particles.position = self.position
    if left:
        hit_particles.scale.x *= -1
    add_sibling(hit_particles)
    self.velocity += Vector2(-2 if left else 2, -1) * knockback
    var numbers = numbers_scene.instantiate()
    numbers.text = str(dmg)
    self.get_parent().add_child(numbers)
    numbers.position = self.position + Vector2(-48, -24)
    if hp <= 0:
        do_death()
    return true

func do_death():
    inv = 0.2
    no_ai = 1
    target = null
    for node in self.find_children("*", "DamageHitbox"):
        node.collision_mask = 0
    await get_tree().create_timer(inv).timeout

    var image: Image = death_tex.get_image()
    var offset = self.position - 0.5 * image.get_size() + Vector2(0.5, 0.5)
    var first_row = null
    for y in range(image.get_height()):
        for x in range(image.get_width()):
            var color = image.get_pixel(x, y)
            if color.a > 0:
                if not first_row:
                    first_row = y
                var particle = DeathParticle.new()
                self.get_parent().add_child(particle)
                particle.position = offset + Vector2(x, y)
                particle.modulate = color
                particle.countdown = (y - first_row) * 0.02

    play_sound(vaporise_sfx)
    drop_gold()
    drop_xp()
    self.queue_free()
    death.emit()
    if enemy_id:
        Globals.set_enemy_flag(enemy_id, true)

func _process(delta):
    inv -= delta
    no_ai -= delta
    detect_time -= delta
    if spare_time:
        spare_time -= delta
    if detection and detect_time <= 0:
        detect_time = 1
        var old_target = target
        target = null
        for body in detection.get_overlapping_bodies():
            if body is Player:
                target = body
                detect_time = 20
                if typeof(target) != typeof(old_target) or target != old_target:
                    no_ai = 1
                    do_detect()
                break
    if spare_time and spare_time <= 0 and no_ai <= 0:
        do_flee()

func do_flee(hazard = false):
    no_ai = 2
    inv = 2
    target = null
    for node in self.find_children("*", "DamageHitbox"):
        node.collision_mask = 0
    if not hazard:
        drop_gold()
    play_sound(flee_sfx if hazard else vaporise_sfx)
    self.material = null
    if enemy_id and not hazard:
        Globals.set_enemy_flag(enemy_id, false)
    spared.emit()
    var tween = get_tree().create_tween()
    tween.tween_property(self, "modulate", Color(self.modulate, 0), 1)
    await tween.finished
    self.queue_free()

func drop_gold():
    for i in dropped_gold:
        var new = gold_scene.instantiate()
        get_parent().add_child(new)
        new.position = self.position
        new.linear_velocity = self.velocity + Vector2(randf_range(-2, 2), randf_range(-2, 0)).normalized() * 100

func drop_xp():
    while dropped_xp >= 15:
        dropped_xp -= 10
        var new = xp_scene.instantiate()
        new.big = true
        get_parent().add_child(new)
        new.position = self.position
        new.velocity = self.velocity + Vector2(randf_range(-2, 2), randf_range(-2, 2)).normalized() * 300
    for i in dropped_xp:
        var new = xp_scene.instantiate()
        get_parent().add_child(new)
        new.position = self.position
        new.velocity = self.velocity + Vector2(randf_range(-2, 2), randf_range(-2, 2)).normalized() * 300


func animated_sprite_play_basic(sprite, default = "default"):
    if inv > 0 and not spare_time or hp <= 0:
        sprite.play("hurt")
        return true
    else:
        sprite.play(default)

func do_detect():
    var detect = detect_scene.instantiate()
    self.add_child(detect)
    detect.position = Vector2(0, -16)
    play_sound(detect_sfx)

func do_spare():
    if spare_time:
        return
    spare_time = 2 + randf() * 3
    self.material = pink_spare_shader if Globals.get_flag("pink_spare") else spare_shader
    print(Globals.get_flag("pink_spare"))
    play_sound(spare_sfx)
    var star = spare_star_scene.instantiate()
    get_parent().add_child(star)
    star.position = self.position + Vector2(0, -20)
    if Globals.get_flag("pink_spare"):
        star.texture = star.pink_texture

func talk(_act):
    pass

func do_check(mname, blurb, shown_atk = atk, shown_def = def, textbox = null):
    if not textbox:
        textbox = $Textbox
    var old_talk_sound = textbox.find_child("AudioStreamPlayer").stream
    textbox.set_talk_sound(textbox_sfx)
    await textbox.show_text(mname.to_upper() + " - ATK: " + str(shown_atk) + " DEF: " + str(shown_def) + "\n" + blurb, 2)
    textbox.set_talk_sound(old_talk_sound)

func check():
    do_check("MissingNo", "Bepis.")
