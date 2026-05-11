extends Boss

const GRAVITY = 1000
const FRICTION = 2000
const TEXTBOX_OFFSET = Vector2(0, -20)

@export var music_trans: AudioStream
@export var music2: AudioStream
@export var music3: AudioStream
@export var cling_spots: TileMapLayer

var sword_down = false
var flip_h = false:
    set(val):
        flip_h = val
        self.scale.y = -1 if flip_h else 1
        self.rotation = PI if flip_h else 0.0


var phase = 1:
    set(val):
        phase = val
        Globals.game_manager.play_stream(boss_music if phase == 1 else music2 if phase == 2 else music3)
var intro_time = 0
var ground_level:
    get():
        return 178 if phase == 1 else -2442
var textbox
var buff:
    set(val):
        match buff:
            "cheer":
                atk -= 2
                def += 1
            "threat":
                def -= 2
                atk += 1
        match val:
            "cheer":
                atk += 2
                def -= 1
            "threat":
                def += 2
                atk -= 1
        buff = val
        $DamageHitbox.atk = atk
var final_attack_done = false
var wall_cling_time = 0

var fallen_warrior = preload("res://music/fallen warrior.wav")
var shadow_amulet = preload("res://items/shadow_amulet.tres")
var strytax_talk = preload("res://sounds/strytax_talk.wav")
var strytax_talk2 = preload("res://sounds/strytax_talk2.wav")

@warning_ignore("unused_signal")
signal spawn_platforms

const second_phase_text = [
    [
        "So I have grown much weaker than I thought...", 
        "Gone are the days when I could defeat a skilled human with ease.", 
        "Curse this aged body! I will not be bested by a child!", 
        "Follow me! Up to the top of the chasm, where you shall see what we are fighting for!"
    ], 
    [
        "No! no! This isn't about the monsters, not any more.", 
        "This is about me! My honor, my freedom!", 
        "I've been cast aside and ignored for long enough...", 
        "This very day, once and for all, I'll show them I was right!", 
        "Follow me! Up to the top of the chasm, where you'll see what I'm fighting for!"
    ]
]

const third_phase_text = [
    "We cannot climb any further. Your path ends here.", 
    "Now die, child of man! With my last strength, I strike at you!", 
    "Witness the rise of the Unyielding!"
]

const death_text = [
    [
        "So... this is how it all ends.", 
        "All my persistence, all my hopes and dreams...", 
        "Look at where that got me. Heheh.", 
        "Dying, alone, in a forgotten corner of the world.", 
        "At last, the Unyielding yields, and the Sword of Perseverance's life is severed."
    ], 
    [
        "Come, human. I have one last thing for you.", 
        "I was given this amulet a long time ago by someone, I do not remember who.", 
        "But I remember there are more like it, given to others.", 
        "I know no more than this... if you want answers, seek the Mind of Patience.", 
        "He would not tell me anything, for he saw my intentions. But perhaps he will tell you.", 
        "And take this amulet. I will not need it where I am going.", 
        "But you... you are strong. You may be able to do what I cannot."
    ], 
    [
        "Goodbye, child of man. Please remember my gift, and use it well.", 
        "Seek your own path. Do not follow in mine.", 
        "I thought I had found a hidden path to freedom, a second way out.", 
        "But the true second way... that is the path which I now tread."
    ]
]

const spare_text = [
    [
        "...why do you not kill me?", 
        "I have used all my strength, and you still refuse to either die, or finish this for good.", 
        "I am so sick of all this.", 
        "All my persistence, all my hopes and dreams...", 
        "Look at where that got me. Heheh.", 
        "Forsaken by all I care about, and bested by a mere child.", 
        "...", 
        "...what?", 
        "What is that you are offering?", 
        "You will... help me jump up there to freedom?", 
        "I doubt it will work, but it is worth a shot.", 
        "These crags are very great, but your determination is greater.", 
        "Perhaps, I never needed your soul.", 
        "Perhaps, your help was all I needed..."
    ], 
    [
        "Are you ready?"
    ], 
    [
        "...the barrier...", 
        "...it was here all along?", 
        "All my efforts...", 
        "......"
    ], 
    [
        "...GO!", 
        "JUST GO!"
    ]
]

const deltarot_text = "[color=yellow]Freedom[/color]'s just an [color=green]old[/color] [color=purple]penumbra phantasm[/color] for [color=gray][[BIG SHOTS]][/color] who think they can [rainbow]do anything[/rainbow] and the [color=blue][wave]world revolves[/wave][/color] around they're [color=red]genocides[/color]"



const text = [
    [
        "...", 
        "......", 
        "Stop!", 
        "Stop distracting me!", 
        "What are you trying to do?", 
        "You cannot stop me.", 
        "I will defeat you!", 
        "With your power, I'll show them all!", 
        "I'll show them I was right!", 
        "...no, no, I want to save them all.", 
        "Why did I say that?", 
        "Am I not trying to save monsterkind?", 
        "Is that not the whole reason I am doing this?", 
        "You are my last hope.", 
        "If I fail, you will be found by others anyway.", 
        "They will use your power and break the barrier themselves.", 
        "So is this all just needless?", 
        "Am I striving to defeat you in vain?"
    ], 
    {
        "talk": [
            "Up, up we go!", 
            "Prepare yourself!", 
            "Your end is now!", 
            "Your slander only strengthens my armor!", 
            "Your praise only sharpens my sword!", 
            "You cannot escape!", 
            "Keep climbing! Never stop!", 
            "I do not fear you!", 
            "I'll show them all!"
        ], 
        "cheer": [
            "Heh! Your words mean nothing to me!", 
            "I can feel the strength surging up within me!", 
            "Your encouragement only makes me stronger!"
        ], 
        "threat": [
            "Weakling! You dare to insult me so?", 
            "Whatever it is you do, I will be prepared!", 
            "My armor will withstand anything you can do!"
        ]
    }, 
    [
        "...you're cheering me on?", 
        "I don't need your praise!", 
        "I've devoted half my life to this!", 
        "And I've given up everything for this cause!", 
        "My position, my dignity... my reputation...", 
        "...my love... my happiness...", 
        "I do not deserve your praise.", 
        "I have gone too far already. I cannot turn back.", 

        "Can't you please just let me win this?", 
        "WHY CAN'T YOU JUST DIE?", 
        "JUST DIE!!!", 
    ]
]

@onready var len_first = len(text[0])
@onready var len_third = len(text[2])

func talk(act):
    if boss_state is Awaiting:
        await textbox.show_text("...", 2)
        return
    if phase == 1 and aggression <= len_third:
        start_second_phase(true)
        return
    if phase == 1 or phase == 3 and aggression > len_third:
        await textbox.show_text(text[0][len_third - aggression], 2)
        if aggression % 2 == 1:
            add_spare()
        else:
            aggression -= 1
    elif phase == 3:
        if act != "cheer" or spare_time:
            await textbox.show_text("...", 2)
            return
        await textbox.show_text(text[2][ - aggression], 2)
        if aggression % 2 == 1:
            add_spare()
        else:
            aggression -= 1
        if aggression == 1:
            talkable = false
    else:
        if act == "talk" and randf() < 0.001:
            await textbox.show_text(deltarot_text, 2)
            return
        await textbox.show_text(text[1][act].pick_random(), 2)
        if act != "talk":
            buff = act

func check():
    if phase < 3:
        do_check("Strytax", "Disgraced warrior, driven mad by the prospect of an exit.", atk * 4, def * 4, textbox)
    else:
        do_check("Strytax", "Will do whatever it takes to prove himself.", atk * 6, def * 5, textbox)

func _ready():
    super._ready()
    $Textbox.set_talk_sound(strytax_talk2)
    for node in $DamageHitbox.get_children():
        node.set_deferred("disabled", true)
    textbox = $Textbox
    remove_child(textbox)
    add_sibling.call_deferred(textbox)

func start_fight():
    intro_time = 5
    aggression = len_first + len_third
    super.start_fight()
    boss_state = state_transition(FencerWhoFences.new())

func _process(delta):
    intro_time -= delta
    super._process(delta)
    for node in $DamageHitbox.get_children():
        node.visible = not node.disabled
    textbox.position = self.position if $AnimatedSprite2D.animation == "kneel" else self.position + TEXTBOX_OFFSET

func damage(_atk, left = false):
    if phase == 2 or hp <= 20 and not final_attack_done or boss_state is Awaiting or boss_state is Dialogue or hp <= 0 or spare_time and spare_time <= 0:
        return
    if final_attack_done and (boss_state is not MegaSlam or boss_state.lifetime < boss_state.attack_start and talkable):
        spare_time = 100
    if not super.damage(_atk, left) or not (boss_state is Idle and boss_state is not Awaiting or boss_state is FencerWhoFences):
        return



    if randf() < 0.4:
        return
    boss_state.successors = [Riposte, Riposte]
    if intro_time <= 0:
        boss_state.successors.append(GroundSlam)
    if phase == 1:
        boss_state.successors.append(Lunge)

func do_death():
    if not final_attack_done:
        hp = 1
        return
    super.do_death()

func do_flee(hazard = false):
    if hazard:
        if no_ai > 0:
            return
        no_ai = 10
        await get_tree().create_timer(1).timeout
        no_ai = 0
        if phase == 3:
            self.position = Vector2(0 if target.position.x > 160 else 320, ground_level)
        else:
            self.position = Vector2(-160 if target.position.x > 160 else 480, ground_level)
        boss_state = state_transition(FencerWhoFences.new())
    else:
        super.do_flee(hazard)

func start_second_phase(spare = false):
    if phase != 1 or boss_state is Dialogue or boss_state is TransitionState:
        return
    var new_state = Dialogue.new()
    new_state.act = "second_phase"
    new_state.spare = spare
    boss_state = state_transition(new_state)

func start_third_phase():
    var new_state = Dialogue.new()
    new_state.act = "third_phase"
    boss_state = state_transition(new_state)
    create_tween().tween_property(self, "modulate", Color.WHITE, 1)

func death_cutscene():
    var new_state = Dialogue.new()
    new_state.act = "death"
    boss_state = state_transition(new_state)
    boss_fight = true
    while boss_state is TransitionState:
        await get_tree().create_timer(0.2).timeout
    while boss_state is Dialogue:
        await get_tree().create_timer(0.2).timeout

func spare_cutscene():
    var new_state = Dialogue.new()
    new_state.act = "spare"
    boss_state = state_transition(new_state)
    boss_fight = true
    spare_time = null
    talkable = false
    $DamageHitbox.hide()
    while boss_state is not Awaiting:
        await get_tree().create_timer(0.2).timeout
    await get_parent().barrier_cutscene()
    new_state = Dialogue.new()
    new_state.act = "spare2"
    boss_state = state_transition(new_state)
    boss_fight = true
    while boss_state is TransitionState:
        await get_tree().create_timer(0.2).timeout
    while boss_state is Dialogue:
        await get_tree().create_timer(0.2).timeout



func state_transition(state: BossState):
    if state is not PositionalState:
        return state
    state.boss = self
    state.predecessor = boss_state
    var dest = state.setup()
    if not dest:
        return state
    var dist = abs(dest[0].x - position.x)
    if phase == 2:
        return SpinJump.new(state, dest[0], dest[1])
    if dest[0].y == ground_level:
        if dist < 20:
            if dest[1] == flip_h:
                return state
            return SpinTurn.new(state, self.position, dest[1])
        elif phase == 1 and dest[1] == flip_h and (dest[0].x < position.x) == flip_h:
            if dist < 60:
                return Fleche.new(state, dest[0], dest[1])
            if dist < 100:
                return DoubleFleche.new(state, dest[0], dest[1])
        return SpinJump.new(state, dest[0], dest[1])
    return StraightJump.new(state, dest[0], dest[1])

func is_position_safe(pos):
    return ((pos.x > -160 and pos.x < 480 and not (100 < pos.x and pos.x < 220)) if phase == 1\
else (pos.x > 40 and pos.x < 280)) and abs(pos.y - ground_level) < 5

func play_animation(animation):
    $AnimatedSprite2D.play(animation)

func basic_physics(delta):
    if abs(self.velocity.x) < FRICTION * delta:
        self.velocity.x = 0
    else:
        self.velocity.x -= FRICTION * sign(self.velocity.x) * delta
    self.velocity.y += GRAVITY * delta

class PositionalState extends BossState:
    func setup():
        return

    func process(delta):
        lifetime -= delta
        if lifetime <= 0:
            boss.boss_state = boss.state_transition(successors.pick_random().new())

class TransitionState extends BossState:
    var dest
    var dest_flip_h

    func _init(state: PositionalState, d, flip_h):
        successors = state
        dest = d
        dest_flip_h = flip_h

    func process(delta):
        lifetime -= delta
        if lifetime <= 0:
            boss.boss_state = successors

class Idle extends PositionalState:
    func start():
        if boss.hp < boss.max_hp * 0.6 and boss.phase == 1:
            boss.start_second_phase()
            return
        lifetime = randf_range(0.5, 1) if boss.intro_time > 0 else 0.2 if boss.phase == 1 else 0.0
        boss.play_animation("default_down" if boss.sword_down else "default")
        if (boss.hp <= 20 or boss.aggression <= 1) and not boss.final_attack_done:
            successors = [ThisIsNoNormalInfinity]
            return
        successors = [Riposte, Riposte] if abs(boss.target.position.x - boss.position.x) < 20\
else [FencerWhoFences, FencerWhoFences, FencerWhoFences, FencerWhoFences]
        if successors[0] is Riposte:
            print("distance riposte")
        if boss.intro_time <= 0:
            successors.append(GroundSlam)
            if abs(boss.target.position.x - 160) < (200 if boss.phase == 1 else 60):
                successors.append(PreAppreciation)
        if boss.phase == 1:
            successors.append_array([Lunge, Lunge])
        if boss.phase == 3:
            successors.append(Infinity)

    func physics_process(delta):
        boss.basic_physics(delta)

class FencerWhoFences extends PositionalState:
    func is_safe(pos, flip_h):
        return boss.is_position_safe(pos) and boss.is_position_safe(pos + Vector2(-6 if flip_h else 6, 0))

    func setup():
        var dist = (boss.target.position.x - boss.position.x) * (-1 if boss.flip_h else 1)
        if 20 <= dist and dist <= 60 and is_safe(boss.position, boss.flip_h):
            return
        for i in range(8):
            var dir = sign(boss.target.velocity.x) if boss.target.velocity.x != 0 and randf() < 0.5 else randi_range(0, 1) * 2 - 1
            var pos = Vector2(boss.target.position.x + boss.target.velocity.x * 0.3 + randi_range(40, 60) * dir, boss.ground_level)
            if is_safe(pos, dir > 0):
                return [pos, dir > 0]

    func start():
        lifetime = 0.4
        successors = [Idle]
        boss.sword_down = not boss.sword_down
        boss.play_animation("basic_down" if boss.sword_down else "basic_up")

    func physics_process(delta):
        boss.basic_physics(delta)

class SpinJump extends TransitionState:
    var old_knockback
    var gravity

    func start():
        lifetime = lifetime if lifetime < 10 else 0.7 if boss.phase < 3 else 0.5
        gravity = GRAVITY * (2 if boss.phase < 3 else 4)
        boss.velocity = (dest - boss.position - 0.5 * Vector2.DOWN * gravity * lifetime ** 2) / lifetime
        boss.velocity.x *= 2
        old_knockback = boss.knockback
        boss.knockback = 0
        boss.flip_h = dest.x < boss.position.x
        boss.sword_down = randf() < 0.5
        boss.play_animation("spin_jump")
        boss.wall_cling_time = 0

    func process(delta):
        boss.rotate(30 * delta * (-1 if boss.flip_h else 1))
        if boss.position.distance_to(dest) < 10 and lifetime < 0.1:
            lifetime = 0
        super.process(delta)

    func physics_process(delta):
        boss.velocity.y += gravity * delta

    func end():
        boss.knockback = old_knockback
        boss.position = dest
        boss.flip_h = dest_flip_h
        boss.velocity = Vector2.ZERO

class SpinTurn extends SpinJump:
    func start():
        lifetime = 0.2
        super.start()

class Fleche extends TransitionState:
    func start():
        lifetime = 0.7
        boss.flip_h = dest.x < boss.position.x
        boss.play_animation("fleche_down" if boss.sword_down else "fleche")

    func physics_process(delta):
        boss.basic_physics(delta)

class DoubleFleche extends TransitionState:
    func start():
        lifetime = 1.3
        boss.flip_h = dest.x < boss.position.x
        boss.play_animation("fleche_long_down" if boss.sword_down else "fleche_long")

    func physics_process(delta):
        boss.basic_physics(delta)

class Riposte extends PositionalState:
    var attacking = false
    var attack_start

    func setup():
        return [Vector2(boss.position.x, boss.ground_level), boss.target.position.x < boss.position.x]

    func start():
        lifetime = 1.3 if boss.phase == 1 else 0.8
        attack_start = 1.0 if boss.phase == 1 else 0.6
        successors = [Idle]
        boss.sword_down = randf() < 0.5
        boss.play_animation("riposte_prepare")
        boss.position.x += 6 if boss.flip_h else -6

    func process(delta):
        super.process(delta)
        if lifetime <= attack_start and not attacking:
            attacking = true
            boss.play_animation("riposte" if boss.phase == 1 else "riposte_short")

    func physics_process(delta):
        boss.basic_physics(delta)

    func end():
        boss.position.x += -6 if boss.flip_h else 6

class StraightJump extends TransitionState:
    var old_knockback

    func start():
        var jump_speed = 300 if boss.phase == 1 else 400

        lifetime = boss.position.distance_to(dest) / jump_speed
        boss.get_tree().create_tween().tween_property(boss, "position", dest, lifetime)
        old_knockback = boss.knockback
        boss.knockback = 0
        boss.flip_h = dest.x < boss.position.x
        boss.sword_down = randf() < 0.5
        boss.play_animation("spin_jump")

    func process(delta):
        boss.rotate(30 * delta * (-1 if boss.flip_h else 1))


        super.process(delta)

    func end():
        boss.knockback = old_knockback
        boss.position = dest
        boss.flip_h = dest_flip_h
        boss.velocity = Vector2.ZERO

class GroundSlam extends PositionalState:
    var old_knockback
    var attack_start
    var attacking = false
    var impact_sfx = preload("res://sounds/impact.wav")

    func setup():
        var x = boss.target.position.x
        if boss.phase == 3:
            x = clamp(x, 100, 220)
        elif x < 160:
            x = clamp(x, -120, 40)
        else:
            x = clamp(x, 280, 440)
        return [Vector2(x, boss.ground_level - 60), x < boss.position.x]

    func start():
        lifetime = 1.5 if boss.phase == 1 else 1.0
        attack_start = 1.0 if boss.phase == 1 else 0.6
        successors = [Idle]
        old_knockback = boss.knockback
        boss.knockback = 0
        boss.play_animation("flying_leap")

    func process(delta):
        super.process(delta)
        if lifetime <= attack_start and not attacking:
            attacking = true
            Globals.game_manager.camera_shake(10 if self is MegaSlam else 5)
            boss.position.y = boss.ground_level
            boss.play_animation("ground_slam")
            boss.play_sound(impact_sfx)
            boss.find_child("MegaSlamParticles" if self is MegaSlam else "SlamParticles").emitting = true

    func end():
        boss.knockback = old_knockback

class PreAppreciation extends PositionalState:
    func setup():
        var flip_h = boss.target.position.x > 160
        if boss.phase == 3:
            return [Vector2(260 if flip_h else 60, boss.ground_level), flip_h]
        return [Vector2(480 if flip_h else -160, boss.ground_level), flip_h]

    func start():
        lifetime = 0.2
        successors = [YouWillAppreciateMyCoolArena]
        boss.play_animation("default_down" if boss.sword_down else "default")

    func physics_process(delta):
        boss.basic_physics(delta)

class YouWillAppreciateMyCoolArena extends BossState:
    const ACCEL = 500
    const MAX_SPEED = 700
    const JUMP_SPEED = 600
    var dest

    func start():
        lifetime = 2
        successors = [PostAppreciation]
        if boss.phase == 3:
            dest = 260 if boss.position.x < 160 else 60
        else:
            dest = 80 if boss.position.x < 160 else 240
        boss.flip_h = boss.position.x > dest
        boss.sword_down = false
        boss.play_animation("spin_jump")
        boss.velocity.x = -200 if boss.flip_h else 200

    func process(delta):
        boss.rotate(30 * delta * (-1 if boss.flip_h else 1))
        if abs(boss.position.x - dest) < 10:
            lifetime = 0
        super.process(delta)

    func physics_process(delta):
        boss.velocity.x = clamp(boss.velocity.x + ACCEL * delta * (-1 if boss.flip_h else 1), - MAX_SPEED, MAX_SPEED)
        boss.velocity.y += GRAVITY * 4 * delta
        if boss.is_on_floor():
            boss.velocity.y = - JUMP_SPEED

    func end():
        boss.position = Vector2(dest, boss.ground_level)
        boss.velocity = Vector2.ZERO
        boss.flip_h = boss.flip_h

class PostAppreciation extends Idle:
    func start():
        super.start()
        lifetime = 0.5

class Dialogue extends FencerWhoFences:
    var act
    var spare
    var waiting = true
    var impact_sfx = preload("res://sounds/impact.wav")

    func is_safe(pos, _flip_h):
        return boss.is_position_safe(pos) and abs(pos.x - 160) < 240

    func setup():
        var out = super.setup()
        if act == "death":
            out = [out[0] if out else Vector2(boss.position.x, boss.ground_level), false]
        return out

    func start():
        successors = [Awaiting]
        boss.play_animation("kneel" if act in ["death", "spare2"]\
else "default_down" if boss.sword_down else "default")
        boss.position.y = boss.ground_level
        boss.velocity = Vector2.ZERO
        if act == "spare2":
            boss.play_sound(impact_sfx)

    func process(delta):
        lifetime = 0.1
        if not waiting or not boss.target.is_on_floor() or abs(boss.target.position.x - boss.position.x) > 100:
            return
        waiting = false
        if act != "spare2":
            boss.target.pause()
        var textbox = boss.textbox
        match act:
            "second_phase":
                Globals.game_manager.play_stream(boss.music_trans)
                await textbox.show_text(second_phase_text[1 if spare else 0])
                await sleep(0.5)
                boss.phase = 2
                successors = [WallClingStart]
                boss.spawn_platforms.emit()
                boss.create_tween().tween_property(boss, "modulate", Color.GRAY, 1)
            "third_phase":
                await textbox.show_text(third_phase_text)
                await sleep(0.5)
                boss.phase = 3
                successors = [GroundSlam]
            "death":
                boss.boss_fight = false
                await sleep(5)
                Globals.game_manager.play_stream(boss.fallen_warrior)
                textbox.set_talk_sound(boss.strytax_talk)
                await textbox.show_text(death_text[0])
                await sleep(1)
                await textbox.show_text(death_text[1])
                var received = Globals.game_manager.ap_check_location(boss.shadow_amulet.item_id)
                await sleep(1)
                await textbox.show_text(death_text[2])
                await sleep(2)
                if not received:
                    boss.get_parent().spawn_amulet()
            "spare":
                boss.boss_fight = false
                await sleep(5)
                textbox.set_talk_sound(boss.strytax_talk)
                await textbox.show_text(spare_text[0])

                await sleep(1)
                await textbox.show_text(spare_text[1])
            "spare2":
                boss.boss_fight = false
                await sleep(2)
                await textbox.show_text(spare_text[2])
                await sleep(1)
                boss.play_animation("default")
                await sleep(1)
                textbox.set_talk_sound(boss.strytax_talk2)
                await textbox.show_text(spare_text[3])
                await sleep(2)
                textbox.set_talk_sound(boss.strytax_talk)
                boss.play_animation("kneel")
        if act != "spare":
            boss.target.unpause()
        lifetime = 0
        super.process(delta)

    func sleep(time):
        await boss.get_tree().create_timer(time).timeout

class WallCling extends PositionalState:
    var heal_sfx = preload("res://sounds/heal.wav")

    func check_row(tilemap: TileMapLayer, flip_h, row):
        var y = tilemap.local_to_map(boss.position).y - row
        for x in range(8, 17, 1) if flip_h else range(7, -2, -1):
            var out = Vector2i(x, y)
            if tilemap.get_cell_tile_data(out):
                return tilemap.map_to_local(out) + Vector2.UP * 10

    func setup():
        const START = 4
        var dist = boss.target.position.y - boss.position.y
        if dist > 80 or dist > 0 and boss.position.distance_squared_to(boss.target.position) > 3000 and randf() < 0.5:
            return
        var flip_h = boss.position.x < 160
        var out = check_row(boss.cling_spots, flip_h, START)
        if out:
            return [out, flip_h]
        for step in range(1, START):
            for _sign in range(1, -2, -2) if randf() < 0.5 else range(-1, 2, 2):
                out = check_row(boss.cling_spots, flip_h, START + step * _sign)
                if out:
                    return [out, flip_h]

    func start():
        lifetime = 0.5
        successors = [WallCling]
        boss.play_animation("wall_cling")
        boss.sword_down = false

    func process(delta):
        if boss.textbox.visible:
            lifetime = 0.5
        else:
            boss.wall_cling_time += delta
            if boss.wall_cling_time > 5:
                boss.wall_cling_time = 0
                if boss.hp < boss.max_hp * 0.8:
                    boss.hp = min(boss.hp + 10, boss.max_hp * 0.8)
                    boss.boss_bar.value = boss.hp
                    boss.play_sound(heal_sfx)


        super.process(delta)

class WallClingStart extends WallCling:
    func setup():
        var flip_h = boss.position.x < 160
        return [Vector2(230 if flip_h else 110, -240), flip_h]

class Awaiting extends Idle:
    func start():

        lifetime = 10000000
        successors = [Awaiting]

class Infinity extends PositionalState:
    var old_knockback
    var attack_start
    var attacking = false
    var arrow_sfx = preload("res://sounds/arrow.wav")
    var warning = preload("res://bullets/strytax_warning.tscn")
    var dest
    var dir

    func setup():
        var flip_h = randf() < 0.5
        var x = clamp(boss.target.position.x + randf_range(60, 100) * (1 if flip_h else -1), 20, 300)
        return [Vector2(x, boss.ground_level - 80), flip_h]

    func start():
        lifetime = 0.5
        attack_start = 0.2
        successors = [Idle, Infinity]
        old_knockback = boss.knockback
        boss.knockback = 0
        boss.play_animation("flying_leap")
        dest = boss.target.position
        if abs(dest.x - boss.position.x) < 40:
            dest.x = boss.position.x + 40 * sign(dest.x - boss.position.x)
        dir = boss.position.direction_to(dest)
        var warn = warning.instantiate()
        warn.position = boss.position
        warn.rotation = dir.angle()
        warn.time = lifetime - attack_start
        boss.add_sibling(warn)

    func process(delta):
        super.process(delta)
        if lifetime <= attack_start and not attacking:
            attacking = true
            boss.position += Vector2.UP * 4
            boss.velocity = dir * 2000
            boss.rotation = dir.angle()
            boss.play_animation("infinity")
            boss.play_sound(arrow_sfx)
        if boss.position.distance_to(dest) < 10 and attacking:
            lifetime = 0

    func end():
        boss.knockback = old_knockback
        boss.position = Vector2(dest.x, boss.ground_level)
        boss.velocity = Vector2.ZERO
        boss.flip_h = boss.flip_h

class ThisIsNoNormalInfinity extends Infinity:
    func start():
        super.start()
        successors = [BoundlessInfinity]

class BoundlessInfinity extends PositionalState:
    var warning = preload("res://bullets/strytax_warning.tscn")
    var clone_scene = preload("res://bullets/strytax_clone.tscn")
    var arrow_sfx = preload("res://sounds/arrow.wav")
    const CENTRE = Vector2(160, -2460)

    func start():
        boss.hide()
        lifetime = 1000000
        for i in range(8):
            await sleep(0.25)
            await spawn_clone(boss.target.position, randf_range(0.5, 1) * pol(i) + PI * 0.5, 0.3)
        for i in range(8):
            await spawn_clone(boss.target.position, randf_range(0.5, 1) * pol(i) + PI * 0.5, 0.3)
        for i in range(3):
            await sleep(0.3)
            spawn_clone(boss.target.position, randf_range(0.5, 1) * pol(i) + PI * 0.5, 0.2)
            await sleep(0.05)
            await spawn_clone(boss.target.position, - randf_range(0.5, 1) * pol(i) + PI * 0.5, 0.2)
        for i in range(2):
            await sleep(0.4)
            for j in range(5):
                spawn_clone(boss.target.position, randf_range(0.5, 1) * pol(i) + PI * 0.5 * pol(j), 0.4)
                await sleep(0.05)
        await sleep(0.4)
        for i in range(8):
            spawn_clone(
                CENTRE + Vector2(randf_range(-60, 60), 
                randf_range(-80, 80)), randf_range( - PI, PI), 0.5
            )
            await sleep(0.05)
        await sleep(0.4)
        for i in range(9):
            spawn_warn(CENTRE, PI * i / 9, 1 - i * 0.05)
            await sleep(0.05)
        await sleep(0.2)
        lifetime = 0
        successors = [MegaSlam]
        boss.position = Vector2(0 if boss.target.position.x > 160 else 320, boss.ground_level)

    func spawn_clone(pos, rot, time):
        spawn_warn(pos, rot, time)
        await sleep(time)
        boss.play_sound(arrow_sfx)
        var clone = clone_scene.instantiate()
        clone.dest = pos
        clone.rotation = rot
        clone.atk = boss.atk
        boss.add_sibling(clone)

    func spawn_warn(pos, rot, time):
        var warn = warning.instantiate()
        warn.position = pos
        warn.rotation = rot
        warn.time = time
        boss.add_sibling(warn)

    func sleep(time):
        await boss.get_tree().create_timer(time).timeout
        while boss.target.process_mode == Node.PROCESS_MODE_DISABLED:
            await boss.get_tree().create_timer(0.1).timeout

    func pol(x):
        return ((x % 2) * 2 - 1)

    func end():
        boss.show()
        boss.final_attack_done = true

class MegaSlam extends GroundSlam:
    func setup():
        var flip_h = boss.position.x > 160
        return [Vector2(160 + (12 if flip_h else -12), boss.ground_level - 80), flip_h]

    func start():
        super.start()
        attack_start = 5
        lifetime = attack_start + 0.5

    func process(delta):
        super.process(delta)
        if lifetime < attack_start - 1 and not boss.talkable:
            boss.talkable = true
            boss.do_spare()
            boss.spare_time = lifetime

class Lunge extends PositionalState:
    func is_safe(pos, flip_h):
        return boss.is_position_safe(pos) and boss.is_position_safe(pos + Vector2(-36 if flip_h else 36, 0))

    func setup():
        var dist = (boss.target.position.x - boss.position.x) * (-1 if boss.flip_h else 1)
        if 40 <= dist and dist <= 80 and is_safe(boss.position, boss.flip_h):
            return
        for i in range(8):
            var dir = sign(boss.target.velocity.x) if boss.target.velocity.x != 0 and randf() < 0.5 else randi_range(0, 1) * 2 - 1
            var pos = Vector2(boss.target.position.x + boss.target.velocity.x * 0.3 + randi_range(40, 80) * dir, boss.ground_level)
            if is_safe(pos, dir > 0):
                return [pos, dir > 0]

    func start():
        lifetime = 1.5
        successors = [Idle]
        if abs(boss.target.position.x - boss.position.x) > 120:
            lifetime = 0
            return
        boss.play_animation("lunge")

    func physics_process(delta):
        boss.basic_physics(delta)

class NoCheesingOnMyWatch extends GroundSlam:
    func start():
        super.start()
        lifetime = attack_start + 0.1

func _on_animated_sprite_2d_animation_changed():
    $DamageHitbox / DamageSpin.set_deferred("disabled", true)
    $DamageHitbox / DamageIdleDown.set_deferred("disabled", $AnimatedSprite2D.animation not in ["default_down", "basic_up", "fleche_down", "fleche_long_down", "lunge"])
    $DamageHitbox / DamageIdleUp.set_deferred("disabled", $AnimatedSprite2D.animation not in ["default", "basic_down", "fleche", "fleche_long"])
    $CollisionDefault.set_deferred("disabled", $AnimatedSprite2D.animation in ["spin_jump", "ground_slam", "wall_cling", "infinity"])
    $CollisionSpin.set_deferred("disabled", $AnimatedSprite2D.animation != "spin_jump" or phase == 2)
    $CollisionSlam.set_deferred("disabled", $AnimatedSprite2D.animation != "ground_slam")
    $CollisionSlam2.set_deferred("disabled", $AnimatedSprite2D.animation != "ground_slam")
    $DamageHitbox / DamageSlamUp.set_deferred("disabled", $AnimatedSprite2D.animation != "flying_leap")
    $DamageHitbox / DamageSlamDown.set_deferred("disabled", $AnimatedSprite2D.animation != "ground_slam")
    $DamageHitbox / DamageSlamShock.set_deferred("disabled", $AnimatedSprite2D.animation != "ground_slam" or boss_state is MegaSlam)
    $DamageHitbox / DamageMegaSlam.set_deferred("disabled", $AnimatedSprite2D.animation != "ground_slam" or boss_state is not MegaSlam)
    $DamageHitbox / DamageSlamShock2.set_deferred("disabled", $AnimatedSprite2D.animation != "ground_slam")

    $DamageHitbox / DamageInfinity.set_deferred("disabled", $AnimatedSprite2D.animation != "infinity")
    $DamageHitbox / DamageRiposteUp.set_deferred("disabled", true)
    $DamageHitbox / DamageRiposteDown.set_deferred("disabled", $AnimatedSprite2D.animation not in ["riposte", "riposte_short"])
    $DamageHitbox / DamageBasicDown.set_deferred("disabled", true)
    $DamageHitbox / DamageLunge1.set_deferred("disabled", true)
    $DamageHitbox / DamageLunge2.set_deferred("disabled", true)
    $DamageHitbox / DamageLunge3.set_deferred("disabled", true)
    $DamageHitbox / DamageLunge4.set_deferred("disabled", true)
    _on_animated_sprite_2d_frame_changed()

func _on_animated_sprite_2d_frame_changed():
    if $AnimatedSprite2D.animation in ["basic_up", "basic_down"]:
        var damage_hitbox = $DamageHitbox / DamageBasicUp if $AnimatedSprite2D.animation == "basic_up" else $DamageHitbox / DamageBasicDown
        if $AnimatedSprite2D.frame == 2:
            self.position.x += -6 if flip_h else 6
            damage_hitbox.set_deferred("disabled", false)
            $DamageHitbox / DamageIdleDown.set_deferred("disabled", $AnimatedSprite2D.animation == "basic_up")
            $DamageHitbox / DamageIdleUp.set_deferred("disabled", $AnimatedSprite2D.animation == "basic_down")
        else:
            damage_hitbox.set_deferred("disabled", true)
    elif $AnimatedSprite2D.animation in ["fleche", "fleche_down", "fleche_long", "fleche_long_down"] and $AnimatedSprite2D.frame > 0:
        self.position.x += -6 if flip_h else 6
    elif $AnimatedSprite2D.animation in ["riposte", "riposte_short"]:
        $DamageHitbox / DamageRiposteUp.set_deferred("disabled", $AnimatedSprite2D.frame not in [2, 3])
        $DamageHitbox / DamageRiposteDown.set_deferred("disabled", $AnimatedSprite2D.frame in [2, 3])
        $DamageHitbox / DamageRiposteSwingUp.set_deferred("disabled", $AnimatedSprite2D.frame != 2)
        $DamageHitbox / DamageRiposteSwingDown.set_deferred("disabled", $AnimatedSprite2D.frame not in [0, 4])
    elif $AnimatedSprite2D.animation == "lunge":
        var dir = -1 if flip_h else 1
        if $AnimatedSprite2D.frame in [1, 2, 3]:
            self.position.x += 4 * dir
        elif $AnimatedSprite2D.frame == 4:
            self.position.x += 9 * dir
            $CollisionDefault.set_deferred("disabled", true)
            $CollisionSlam.set_deferred("disabled", false)
        elif $AnimatedSprite2D.frame == 5:
            self.position.x -= 9 * dir
            $CollisionDefault.set_deferred("disabled", false)
            $CollisionSlam.set_deferred("disabled", true)
        elif $AnimatedSprite2D.frame in [6, 7, 8]:
            self.position.x -= 4 * dir
        $DamageHitbox / DamageIdleDown.set_deferred("disabled", $AnimatedSprite2D.frame not in [0, 8])
        $DamageHitbox / DamageLunge1.set_deferred("disabled", $AnimatedSprite2D.frame not in [1, 7])
        $DamageHitbox / DamageLunge2.set_deferred("disabled", $AnimatedSprite2D.frame not in [2, 6])
        $DamageHitbox / DamageLunge3.set_deferred("disabled", $AnimatedSprite2D.frame not in [3, 5])
        $DamageHitbox / DamageLunge4.set_deferred("disabled", $AnimatedSprite2D.frame != 4)

func _on_animated_sprite_2d_animation_looped():
    $DamageHitbox / DamageSpin.set_deferred("disabled", $AnimatedSprite2D.animation != "spin_jump" or phase == 2)
    $DamageHitbox / DamageSlamShock.set_deferred("disabled", true)
    $DamageHitbox / DamageMegaSlam.set_deferred("disabled", true)
    $DamageHitbox / DamageSlamShock2.set_deferred("disabled", true)

func _on_animated_sprite_2d_animation_finished():
    if boss_state is Fleche and $AnimatedSprite2D.animation in ["fleche", "fleche_down"]\
or boss_state is DoubleFleche and $AnimatedSprite2D.animation in ["fleche_long", "fleche_long_down"]\
or boss_state is Riposte and $AnimatedSprite2D.animation in ["riposte", "riposte_short"]\
or boss_state is Lunge and $AnimatedSprite2D.animation == "lunge":
        boss_state.lifetime = 0
        $DamageHitbox / DamageRiposteDown.set_deferred("disabled", true)
        $DamageHitbox / DamageRiposteUp.set_deferred("disabled", true)
