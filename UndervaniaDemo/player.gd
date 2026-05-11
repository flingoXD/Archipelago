extends CharacterBody2D
class_name Player

const ACCEL = 2000
const MAX_SPEED = 200
const GRAVITY = 960
const JUMP_SPEED = 320
const JUMP_LEN = 0.5
const JUMP_LATENCY = 0.05
const STAGGER_SPEED = 800
const STAGGER_ROTATE = 20
const KNOCKBACK = 200
const GLIDE_SPEED = 150
const GLIDE_START_SPEED = 10
const ATTACK_COOLDOWN = 0.2
const ACT_COOLDOWN = 3
const ACT_RANGE = 200
const INVENTORY_SIZE = 8
const LANTERN_LIGHT = 0.6
const LANTERN_COLOR = Color("#ffc000")

const WEAPON_POS = {
    "default": [[Vector2(0.5, 8.5)]], 
    "walk": [[Vector2(1.5, 8.5)], [Vector2(0.5, 8.5)]], 
    "act": [[Vector2(5.5, 3.5), - PI * 0.5]], 
    "act_walk": [[Vector2(5.5, 4.5), - PI * 0.5]], 
    "down": [[Vector2(6.5, 7.5)]], 
    "up": [[Vector2(5.5, 7.5)]], 
    "frisk_dance": [[Vector2(6.5, 7.5)], [Vector2(5.5, 7.5)]]
}

var gravity_scale = 1
var gravity:
    get():
        return GRAVITY * gravity_scale
var wind = 0
var jump_time = 0
var attack_time = 0
var coyote_time = 0
var fall_speed = 0
var gliding = false
var glide_cooldown = 0
var jump = false
var jumping = false
var look = "default"
var look_dir = Vector2.RIGHT
var flip_h = false:
    set(val):
        flip_h = val
        self.scale.y = -1 if flip_h else 1
        self.rotation = PI if flip_h else 0.0
var paused = 0
var hazard_respawn = Vector2.ZERO
var act_time = 0
var parry_time = 0
var item_time = 0
var door_move = Vector2.ZERO
var attacking = false
var dodges = 0
var staggered = false
var stagger_time = 0
var fighting = []
var parried = false

var light_override = 1:
    set(val):
        if val == 0:
            val = 1
        light_override = val
        if Globals.has_ability("lantern") and val < LANTERN_LIGHT:
            $PointLight2D2.color = LANTERN_COLOR.lerp(Color.WHITE, val / LANTERN_LIGHT)
            val = LANTERN_LIGHT
        else:
            $PointLight2D2.color = Color.WHITE
        $PointLight2D2.texture_scale = val
        $PointLight2D2.color.a = pow(val, 0.7)

var selected = null:
    set(val):
        if selected == val:
            return
        if selected:
            selected.selected = false
        if val:
            val.selected = true
        selected = val

var soul_mode = SoulMode.Red.new():
    set(val):
        if soul_mode:
            soul_mode.player = self
            soul_mode.end()
        soul_mode = val
        if val:
            val.player = self
            val.start()

var soul_color = null
var moves_disabled = false

var player_name = "Papyru"
var hp: int = 20
var max_hp: int = 20:
    set(val):
        if val > max_hp:
            hp += val - max_hp
        max_hp = val
var atk: int = 10
var def: int = 10
var inv = 0
var gold: int = 0
var xp: int = 0:
    set(val):
        if val > xp:
            $XpAudio.play()
        xp = val
        lvl = get_lvl_from_xp(xp)
var lvl: int = 1:
    set(val):
        if lvl < val and lvl != 0:
            play_sound(levelup_sfx)
        lvl = val
        if lvl == 20:
            max_hp = 99
            atk = 30
            def = 30
        elif lvl > 0:
            max_hp = 16 + 4 * lvl
            atk = 8 + 2 * lvl
            def = 9 + ceil(0.25 * lvl)

var inventory = []
var weapon
var armour
var atk_mod = 0
var def_mod = 0

signal hud_act(act)

var numbers_scene = preload("res://objects/numbers.tscn")
var slash_sfx = preload("res://sounds/slash.wav")
var hurt_sfx = preload("res://sounds/player_hurt.wav")
var fall_sfx = preload("res://sounds/impact.wav")
var heal_sfx = preload("res://sounds/heal.wav")
var select_sfx = preload("res://sounds/select.wav")
var levelup_sfx = preload("res://sounds/levelup.wav")
var soul_sfx = preload("res://sounds/soul_switch.wav")
var select_shader = preload("res://objects/soul_mode.tres")
var textbox_sfx = preload("res://sounds/talk_textbox.wav")
var parry_sfx = preload("res://sounds/clink.wav")
var buy_item_sfx = preload("res://sounds/buy_item.wav")
var gold_sfx = preload("res://sounds/gold.wav")
var act_popup_scene = preload("res://objects/act_popup.tscn")
var item_sfx = preload("res://sounds/item.wav")

func play_sound(stream, pitch_variance = 0.0):
    var playback = AudioStreamPlayer.new()
    playback.stream = stream
    if pitch_variance:
        playback.pitch_scale = randf_range(1 - pitch_variance, 1 + pitch_variance)
    playback.connect("finished", func():
        playback.queue_free()
    )
    self.get_parent().add_child(playback)
    playback.play()













func get_lvl_from_xp(x):
    return min(floor(pow(floor(x * 0.1), 0.4)) + 1, 20)

func _ready():
    $Textbox.set_talk_sound(textbox_sfx)

func _process(delta):
    handle_attacks(delta)
    inv -= delta
    handle_acts(delta)

func _physics_process(delta):
    handle_motion(delta)
    handle_looks(delta)
    play_anims()
    move_and_slide()

func pause():
    paused += 1

func unpause():
    paused = max(paused - 1, 0)
    door_move = Vector2.ZERO

func handle_looks(delta):
    if self.velocity.y > STAGGER_SPEED:
        $AnimatedSprite2D.rotate(delta * STAGGER_ROTATE)
    else:
        $AnimatedSprite2D.rotation = 0

    if self.velocity.x != wind:
        look_dir = Vector2.RIGHT
        return

    var up = Input.is_action_pressed("up") and paused == 0 and Engine.time_scale == 1
    var down = Input.is_action_pressed("down") and paused == 0 and Engine.time_scale == 1
    if up and down:
        look = "frisk_dance"
        look_dir = Vector2.ZERO
    elif up:
        look = "up"
        look_dir = Vector2.UP * 3
    elif down:
        look = "down"
        look_dir = Vector2.DOWN * 3
    elif look == "frisk_dance":
        look = "down"
    elif look in ["up", "down"]:
        look_dir = Vector2.ZERO
    else:
        look_dir = Vector2.RIGHT

func handle_attacks(delta):
    var attack = Input.is_action_just_pressed("attack") and look == "default" and paused == 0 and attack_time < - ATTACK_COOLDOWN and not attacking and self.velocity.y <= STAGGER_SPEED
    if attack:
        attacking = true
    elif not Input.is_action_pressed("attack"):
        attacking = false
    attack_time -= delta
    parry_time -= delta
    if attack_time > 0:
        if attack_time <= 0.03 and $Slash / AnimatedSprite2D.is_playing():
            $Slash.show()
            $Slash.monitoring = true
    elif attack:
        $Slash / AnimatedSprite2D.play("default")
        play_sound(slash_sfx)
        hud_act.emit("attack")
        look = "attack"
        attack_time = 0.05
        if weapon and weapon.item_id == "toy_knife":
            parry_time = 0.2
        if len(fighting) > 0:
            act_time = max(act_time, ACT_COOLDOWN * 0.5)
        Engine.time_scale = 0.2
    elif look == "attack":
        Engine.time_scale = 1
        look = "default"
        $Slash.hide()

    if not $Slash.visible or not $Slash.monitoring:
        return
    for body in $Slash.get_overlapping_bodies():
        if body is Enemy and body.visible and weapon != null:
            if parried and armour and armour.item_id == "shadow_amulet":
                body.damage(atk + atk_mod + 5, flip_h)
                parried = false
            elif weapon != null:
                body.damage(atk + atk_mod, flip_h)

func play_anims():
    if staggered:
        $AnimatedSprite2D.play("stagger")
        $AnimatedSprite2D / Weapon.hide()
        return

    var cur_wind = 0 if paused > 0 else wind
    if self.velocity.x != cur_wind:

        if look == "attack":
            $AnimatedSprite2D.play("act_walk")
        else:
            $AnimatedSprite2D.play("walk")
            look = "default"
    elif look == "attack":
        $AnimatedSprite2D.play("act")
    else:
        $AnimatedSprite2D.play(look)

    if gliding:
        $AnimatedSprite2D / Glide.show()
        $AnimatedSprite2D / Glide.play("default" if look in ["up", "down", "frisk_dance"] else "side")
        if look == "up":
            $AnimatedSprite2D / Glide.show_behind_parent = false
            $AnimatedSprite2D / Glide.position.x = -0.5
        else:
            $AnimatedSprite2D / Glide.show_behind_parent = true
            $AnimatedSprite2D / Glide.position.x = 0.5
    else:
        $AnimatedSprite2D / Glide.hide()

    $AnimatedSprite2D / Weapon.play(weapon.item_id if weapon else "default")
    if $AnimatedSprite2D.animation in WEAPON_POS:
        $AnimatedSprite2D / Weapon.show()
        var pos = WEAPON_POS[$AnimatedSprite2D.animation][$AnimatedSprite2D.frame]
        $AnimatedSprite2D / Weapon.position = pos[0]
        $AnimatedSprite2D / Weapon.rotation = pos[1] if len(pos) > 1 else 0
    else:
        $AnimatedSprite2D / Weapon.hide()

func damage(enemy_atk, left = null):
    if inv > 0:
        return
    if dodges > 0:
        dodges -= 1
        inv = 0.5
        play_sound(gold_sfx)
        if armour and armour.item_id == "shadow_amulet":
            parried = true
        return
    var dmg = max(roundi(enemy_atk - (def + def_mod) * 0.2 + max_hp * 0.1 - 2), 1)
    if not Globals.game_manager.inf_health:
        hp -= dmg
    play_sound(hurt_sfx)
    inv = 0.5
    if left != null:
        self.velocity += Vector2(-2 if left else 2, -1) * KNOCKBACK
        flip_h = not left
        if self.velocity.y < - JUMP_SPEED:
            self.velocity.y = - JUMP_SPEED
        if jump_time > JUMP_LATENCY:
            jump_time = JUMP_LATENCY
    get_parent().hurt_vignette()
    var numbers = numbers_scene.instantiate()
    numbers.text = str(dmg)
    get_parent().add_child(numbers)
    numbers.position = self.position + Vector2(-48, -24)

func heal(amount):
    hp = clamp(hp + amount, 0, max_hp)
    if amount > 0:
        play_sound(heal_sfx)
    elif amount < 0:
        play_sound(hurt_sfx)

func handle_motion(delta):
    var left = Input.is_action_pressed("left") and not paused
    var right = Input.is_action_pressed("right") and not paused
    if Input.is_action_just_pressed("jump") and not paused:
        jump = true
    elif Input.is_action_just_released("jump") or paused:
        jump = false
    var holding_jump = Input.is_action_pressed("jump") and not paused
    var cur_wind = 0 if paused > 0 else wind

    if attack_time > 0:
        pass
    elif left and not right:
        self.velocity.x = max(self.velocity.x - ACCEL * delta, cur_wind - MAX_SPEED)
        flip_h = true
    elif right and not left:
        self.velocity.x = min(self.velocity.x + ACCEL * delta, cur_wind + MAX_SPEED)
        flip_h = false
    elif abs(self.velocity.x - cur_wind) < ACCEL * delta:
        self.velocity.x = cur_wind
    else:
        self.velocity.x -= ACCEL * delta * sign(self.velocity.x - cur_wind)
    if look in ["up", "down", "frisk_dance"]:
        flip_h = false

    if is_on_floor():
        coyote_time = 0.05
        gliding = false
        glide_cooldown = 0
        stagger_time -= delta
        if fall_speed > STAGGER_SPEED:
            do_stagger()
    else:
        coyote_time -= delta
        glide_cooldown -= delta
        if stagger_time > 0:
            stagger_time = 0
    if stagger_time <= 0 and staggered:
        staggered = false
        $CollisionStagger.set_deferred("disabled", true)
        $CollisionShape2D.set_deferred("disabled", false)
        unpause()
    fall_speed = self.velocity.y
    if jump and coyote_time > 0 and not staggered:
        self.velocity.y = - JUMP_SPEED
        jump_time = JUMP_LEN
        coyote_time = 0


    if jump and not jumping and jump_time <= JUMP_LATENCY and coyote_time <= 0 and glide_cooldown <= 0 and Globals.has_ability("glide") and not moves_disabled:
        gliding = true
        self.velocity.y = max( - JUMP_SPEED, self.velocity.y - GLIDE_START_SPEED)
    if gliding and not holding_jump:
        gliding = false
        glide_cooldown = 0.4


    self.velocity.y += gravity * delta * (0.3 if jump_time > 0 or gliding else 1.0)
    jump_time -= delta
    if is_on_ceiling():
        jump_time = 0
    elif not jump:
        jump_time = clamp(jump_time, 0, JUMP_LATENCY)
    if jump_time <= 0 and jumping:
        jump = false
    if gliding and self.velocity.y > GLIDE_SPEED:
        self.velocity.y = GLIDE_SPEED
    jumping = jump and glide_cooldown <= 0


    if abs(door_move.x) > abs(self.velocity.x) * sign(door_move.x):
        self.velocity.x = door_move.x
    if abs(door_move.y) > abs(self.velocity.y) * sign(door_move.y):
        self.velocity.y = door_move.y

func handle_acts(delta):
    if paused > 0:
        selected = null
        return
    item_time = item_time - delta if len(fighting) > 0 else 0
    if Input.is_action_just_pressed("heal") and item_time <= 0 and await get_parent().item_use() and len(fighting) > 0:
        item_time = 5
        act_time = 5
        hud_act.emit("item")
    elif Input.is_action_just_pressed("inventory") and len(fighting) == 0:
        get_parent().inventory_open()
    if Globals.has_any_act_ability() and act_time <= 0:
        selected = get_closest_entity()
        if not selected:
            return
        for act in Globals.talk_acts:
            if Globals.has_ability(act) and Input.is_action_just_pressed(Globals.input_keys[act]):
                do_act_popup(act)
                if selected is NPC:
                    pause()
                    await selected.talk(act)
                    await get_tree().create_timer(0.5).timeout
                    unpause()
                else:
                    selected.talk(act)
                    act_time = ACT_COOLDOWN
                return
        if Globals.has_ability("check") and Input.is_action_just_pressed(Globals.input_keys["check"]) and selected is not NPC:
            do_act_popup("check")
            selected.check()
            if len(fighting) > 0:
                act_time = ACT_COOLDOWN
    else:
        act_time = act_time - delta if len(fighting) > 0 else 0
        selected = null

func do_act_popup(act):
    play_sound(select_sfx)
    var popup = act_popup_scene.instantiate()
    add_child(popup)
    popup.play(act)
    hud_act.emit(act)

func get_closest_entity():
    var out = null
    var dist = ACT_RANGE
    var level_children = []
    var processing = [get_parent().level]
    while len(processing) > 0:
        var node = processing.pop_back()
        processing.append_array(node.get_children())
        level_children.append(node)
    for entity: Node in level_children:
        if is_talkable(entity) and get_act_rank(out) <= get_act_rank(entity):
            var new_dist = self.global_position.distance_to(entity.global_position)
            if new_dist < ACT_RANGE and (new_dist < dist or get_act_rank(out) < get_act_rank(entity)):
                dist = new_dist
                out = entity
    return out

func get_act_rank(node):
    if node is NPC:
        return 2
    elif node is Enemy:
        return 1 if node.spare_time else 3
    else:
        return 0

func is_talkable(node):
    if (node is Enemy or node is NPC) and node.visible and node.talkable:
        return true
    return false

func set_soul_mode(mode):
    soul_mode = mode.new()
    play_sound(soul_sfx)
    if soul_color:
        $HeartShapedObject.show()
        $HeartShapedObject.modulate = soul_color
        $HeartShapedObject / HeartAnim.scale = Vector2(1, 1)
        $HeartShapedObject / HeartAnim.modulate = Color.WHITE
        var tween = get_tree().create_tween().set_parallel()
        tween.tween_property($HeartShapedObject / HeartAnim, "scale", Vector2(2, 2), 0.5)
        tween.tween_property($HeartShapedObject / HeartAnim, "modulate", Color.TRANSPARENT, 0.5)
        $AnimatedSprite2D.material = select_shader
        $AnimatedSprite2D.material.set_shader_parameter("line_color", soul_color)
    else:
        $HeartShapedObject.hide()
        $AnimatedSprite2D.material = null

func wield(item):
    if weapon:
        inventory.append(weapon)
        weapon.on_unwield(self)
    weapon = item
    if item:
        item.on_wield(self)

func wear(item):
    if armour:
        inventory.append(armour)
        armour.on_unwear(self)
    armour = item
    if item:
        item.on_wear(self)

func add_item(item):
    if not item:
        return true
    if len(inventory) < INVENTORY_SIZE:
        
        inventory.append(item)
        item.on_pickup(self)
        return true
    return false

func take_item(item):
    for i in range(len(inventory)):
        var out = inventory[i]
        if out and out.item_id == item.item_id:
            play_sound(item_sfx)
            return inventory.pop_at(i)

func can_parry(body, direct = false):
    return body.physical and parry_time > 0\
and (($Slash.overlaps_area(body) if body is Area2D else $Slash.overlaps_body(body)) or direct)

func parry():
    if inv > 0:
        return
    play_sound(parry_sfx, 0.2)
    inv = 0.5
    Globals.game_manager.pause()
    $GPUParticles2D.emitting = true
    $Slash.monitoring = false
    await get_tree().create_timer(0.2, true, false, true).timeout
    Globals.game_manager.unpause()
    if armour and armour.item_id == "shadow_amulet":
        parried = true

func spend_gold(amount):
    if amount > gold:
        return false
    gold -= amount
    play_sound(buy_item_sfx)
    return true

func earn_gold(amount):
    gold += amount
    $GoldAudio.play()

func do_stagger():
    $AnimatedSprite2D.rotation = 0
    self.velocity.x = 0
    staggered = true
    $CollisionStagger.set_deferred("disabled", false)
    $CollisionShape2D.set_deferred("disabled", true)
    pause()
    play_sound(fall_sfx)
    stagger_time = 1
