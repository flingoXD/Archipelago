extends Boss

var flapaway_sfx = preload("res://sounds/decibat_flapaway.wav")

const GRAVITY = 300
const SPEED = 40
const JUMP_SPEED = 200
const JUMP_GRAVITY = 600

var aggro_timer = 0
var aggro_change = -1
var aggroed = false
var min_aggro = 3
var max_aggro = 7

const text = [
    "Don't shhy away. Hushh hushh!", 
    "Whhispers only please. Hushh hushh!", 
    "Hushh puppy!", 
    "Don't move. Don’t make a sound. Hushh hushh!", 
    "Don't speak. Don't say a word. Hushh hushh!"
]

const angy_text = [
    "Getting too loud here! HUSHH HUSHH!", 
    "Ow ow ow! Hushh HUSHH HUSHH!"
]

const happy_text = [
    "More quiet please...", 
    "You hhear that? No? Good...", 
    "Sweet silence..."
]

const spare_text = [
    "I declare you an honorary sentinel of silence.", 
    "I trust you to keep peace and order hhere.", 
    "Meanwhile I shall go conquer new lands in the name of quiet.", 
    "This is a very hhigh honor so keep it hhush hhush."
]

func talk(_act):
    if not aggroed:
        if aggro_change < 1:
            aggro_change += 1
        add_spare( - aggro_change)
    boss_music.stream_mask = 2 ** clamp(aggression - 1, 0, 7)
    get_parent().get_parent().play_stream(boss_music)
    if aggression >= 9:
        boss_state.successors = [PreEscape]
    if aggression > max_aggro:
        max_aggro = aggression
        $Textbox.show_text(angy_text[aggression - 8], 2)
    else:
        $Textbox.show_text(text[randi() % len(text)], 2)
    aggroed = true

func check():
    do_check("Decibat", "Missing his quiet solitude.")
    aggroed = true

func start_animation():
    $AnimatedSprite2D.play("default")

func _ready():
    super._ready()
    initial_state = Idle
    boss_music.stream_mask = 16

func _process(delta):
    super._process(delta)
    if boss_fight:
        aggro_timer += delta
        if aggro_timer >= 20:
            aggro_check()
            aggro_timer = 0
    var default = "angy" if aggro_change > 0 else "happy" if aggro_change < 0 and aggression < 3 else "default"
    animated_sprite_play_basic($AnimatedSprite2D, default)

func aggro_check():
    if aggroed:
        aggroed = false
        return
    if aggro_change > -1:
        aggro_change -= 1
    var temp_aggro = aggression + aggro_change
    if temp_aggro < min_aggro:
        min_aggro = temp_aggro
        await $Textbox.show_text(happy_text[2 - temp_aggro], 2)
    add_spare( - aggro_change)
    boss_music.stream_mask = 2 ** clamp(aggression - 1, 0, 7)
    get_parent().get_parent().play_stream(boss_music)

func damage(_atk, left = false):
    super.damage(_atk, left)
    aggroed = true
    if randf() < 0.6:
        boss_state.successors = [PreTeleport if boss_state is not PreTeleport else TraitorLordAndLadyAndTheirSonJeff]

func death_cutscene():
    talkable = false
    $AnimatedSprite2D.speed_scale = 2
    self.velocity = Vector2.ZERO
    await get_tree().create_timer(3).timeout

func spare_cutscene():
    talkable = false
    $AnimatedSprite2D.speed_scale = 1
    self.velocity = Vector2.ZERO
    target.pause()
    var tween
    var dist = abs(target.position.x - self.position.x)
    if self.position.y < -20 or self.position.y > 40 or dist > 100:
        var dest = Vector2(clamp(self.position.x, target.position.x - 100, target.position.x + 100), clamp(self.position.y, -20, 40))
        tween = get_tree().create_tween()
        tween.tween_property(self, "position", dest, self.position.distance_to(dest) * 0.02)
        await tween.finished
    self.velocity = Vector2.ZERO
    await get_tree().create_timer(1).timeout
    await $Textbox.show_text(spare_text)
    $AnimatedSprite2D.speed_scale = 2
    Globals.set_flag("decibat_happy", true)
    tween = get_tree().create_tween()
    tween.tween_interval(0.75)
    tween.tween_callback( func(): $AnimatedSprite2D.speed_scale = 1)
    tween.tween_callback( func(): play_sound(flapaway_sfx))
    tween.tween_property(self, "position", self.position + Vector2.UP * 300, 1)
    await get_tree().create_timer(0.5).timeout
    target.unpause()

class Idle extends BossState:
    var speed
    var teleport_time = 0

    func start():
        lifetime = randi_range(2, 4)
        successors = [Idle, Idle, MossMother, TooManyWaves, TraitorLord, TraitorLordAndLadyAndTheirSonJeff]
        var dir = sign(boss.target.position.x - boss.position.x)
        var dist = abs(boss.target.position.x - boss.position.x)
        speed = SPEED * (1 if boss.position.x < 60 else -1 if boss.position.x > 1660 else dir if dist > 200 else - dir if dist < 100 else randi_range(0, 1) * 2 - 1)
        boss.find_child("AnimatedSprite2D").speed_scale = 1

    func process(delta):
        super.process(delta)
        var dist = abs(boss.target.position.x - boss.position.x)
        if dist > 300 or dist < 40:
            teleport_time += delta
            if teleport_time > 2:
                successors = [PreTeleport]

    func physics_process(delta):
        boss.velocity.y += GRAVITY * delta
        if boss.velocity.y > 0 and randf() < boss.position.y * 0.01:
            boss.velocity.y = - JUMP_SPEED
            boss.velocity.x = speed

class PreTeleport extends BossState:
    func start():
        lifetime = 0.75
        successors = [Teleport]
        boss.find_child("AnimatedSprite2D").speed_scale = 2
        boss.velocity = Vector2.ZERO

class Teleport extends BossState:
    var dest

    func start():
        lifetime = 2
        successors = [Idle, MossMother, TraitorLord]
        var dist = abs(boss.target.position.x - boss.position.x)
        dest = Vector2.ZERO
        while dest.x < 60 or dest.x > 1660:
            dest = Vector2(
                boss.target.position.x + (randi_range(-20, 20) + (160 if dist > 200 else 300)) * (randi_range(0, 1) * 2 - 1), 
                randi_range(-20, 20)
            )
        boss.velocity = (dest - boss.position - 0.5 * Vector2.DOWN * JUMP_GRAVITY * lifetime ** 2) / lifetime
        boss.velocity.x *= 2
        await boss.get_tree().create_timer(0.1).timeout
        boss.find_child("AnimatedSprite2D").speed_scale = 1

    func physics_process(delta):
        boss.velocity.y += JUMP_GRAVITY * delta

class MossMother extends BossState:
    var stalactite = preload("res://bullets/decibat_stalactite.tscn")

    func start():
        lifetime = 1.5
        successors = [Idle]
        boss.find_child("AnimatedSprite2D").speed_scale = 2
        boss.velocity = Vector2.ZERO

    func end():
        for i in range(randi_range(5, 8)):
            var bullet = stalactite.instantiate()
            boss.add_sibling(bullet)
            bullet.position.x = boss.target.position.x + randi_range(-120, 120)
            bullet.position.y = -120 + randi_range(-40, 40)

class TooManyWaves extends BossState:
    var ripple = preload("res://bullets/decibat_ripple.tscn")
    var ripple_sfx = preload("res://sounds/decibat_ripple.wav")
    var ripples_done = 0
    var timer = 0

    func start():
        lifetime = randi_range(2, 4)
        successors = [Idle]
        boss.find_child("AnimatedSprite2D").speed_scale = 2
        boss.velocity = Vector2.ZERO

    func process(delta):
        super.process(delta)
        timer += delta
        if fmod(timer, 1) >= 0.5 and floor(timer) >= ripples_done:
            ripples_done += 1
            var bullet = ripple.instantiate()
            boss.add_sibling(bullet)
            bullet.position = boss.position
            bullet.velocity = (boss.target.position - boss.position).normalized() * bullet.SPEED
            boss.play_sound(ripple_sfx)

class TraitorLord extends BossState:
    var wave = preload("res://bullets/decibat_wave.tscn")
    var wave_sfx = preload("res://sounds/decibat_wave.wav")
    var waves_done = 0
    var timer = 0

    func start():
        lifetime = randi_range(1, 4)
        successors = [Idle, PreTeleport]
        boss.find_child("AnimatedSprite2D").speed_scale = 2
        boss.velocity = Vector2.ZERO

    func process(delta):
        super.process(delta)
        timer += delta
        if fmod(timer, 1) >= 0.5 and floor(timer) >= waves_done:
            waves_done += 1
            spawn_wave()

    func get_rotation():
        if boss.target.position.y - boss.position.y > 2 * abs(boss.target.position.x - boss.position.x):
            return PI * 0.5
        elif boss.target.position.x < boss.position.x:
            return PI
        else:
            return 0

    func spawn_wave():
        var bullet = wave.instantiate()
        boss.add_sibling(bullet)
        bullet.position = boss.position
        bullet.rotation = get_rotation()
        boss.play_sound(wave_sfx)

class TraitorLordAndLadyAndTheirSonJeff extends TraitorLord:
    var wave2_sfx = preload("res://sounds/decibat_wave2.wav")

    func spawn_wave():
        boss.play_sound(wave2_sfx)
        var rot = get_rotation()
        for i in range(3):
            var bullet = wave.instantiate()
            boss.add_sibling(bullet)
            bullet.position = boss.position
            bullet.rotation = rot
            await boss.get_tree().create_timer(0.1).timeout

class PreEscape extends PreTeleport:
    func start():
        super.start()
        successors = [Escape]

    func end():
        boss.play_sound(boss.flapaway_sfx)

class Escape extends BossState:
    func start():
        lifetime = 1
        successors = [Escape]
        boss.velocity.y = -1000
        boss.find_child("AnimatedSprite2D").speed_scale = 1

    func physics_process(delta):
        boss.velocity.y += JUMP_GRAVITY * delta

    func end():
        boss.do_despawn()

func do_despawn():
    boss_fight = false
    target = null
    talkable = false
    Globals.set_enemy_flag(enemy_id, false)
    Globals.game_manager.play_stream(end_music)
    boss_bar.discard()
    spared.emit()
