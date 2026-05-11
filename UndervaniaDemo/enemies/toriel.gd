extends Boss

var toriel_talk = preload("res://sounds/toriel_talk.wav")
var toriel_talk2 = preload("res://sounds/toriel_talk2.wav")
var this_scene = load("res://enemies/toriel.tscn")
var fallen_down = preload("res://music/fallen down.wav")
var hd_death_tex = preload("res://sprites/toriel_hd_death.png")

@export var sealed_vassal: AudioStreamGroup
@export var battle_rig: Node2D

const sealed_masks = [1, 2, 4, 8, 16, 96, 160]

var start_pos
var aggro_timer = 0
var min_aggro = 1000
var enraged = false
var hd_remaster = Globals.get_persistent_flag("silly_shader") == "hd_remaster"

const text = [
    "...", 
    "......", 
    ".........", 
    "...?", 
    "What are you doing?", 
    "Attack or run away!", 
    "What are you proving this way?", 
    "Fight me or leave!", 
    "Stop it.", 
    "Stop looking at me that way.", 
    "Go away!", 
    "...", 
    "......", 
    "I know you want to go home, but...", 
    "But please... go upstairs now.", 
    "I promise I will take good care of you here.", 
    "I know we do not have much, but...", 
    "We can have a good life here.", 
    "Why are you making this so difficult?", 
    "Please, go upstairs.", 
    "...", 
    "Ha ha...", 
    "Pathetic, is it not? I cannot save even a single child.", 
    "..."
]

const end_text = [
    [
        "No, I understand.", 
        "You would just be unhappy trapped down here.", 
        "The RUINS are very small once you get used to them.", 
        "It would not be right for you to grow up in a place like this.", 
        "My expectations... My loneliness... My fear...", 
        "For you, my child... I will put them aside."
    ], 
    [
        "If you truly wish to leave the RUINS...", 
        "I will not stop you.", 
        "However, when you leave...", 
        "Please do not come back.", 
        "I hope you understand.", 
        "Goodbye, my child."
    ], 
    [
        "Urgh...", 
        "You are stronger than I thought...", 
        "Listen to me, small one...", 
        "If you go beyond this door,", 
        "Keep walking as far as you can.", 
        "Eventually you will reach an exit.", 
        "[shake rate=20.0 level=5]......[/shake]", 
        "[shake rate=20.0 level=5][color=red]ASGORE[/color]... Do not let [color=red]ASGORE[/color] take your soul.[/shake]", 
        "[shake rate=20.0 level=5]His plan cannot be allowed to succeed.[/shake]", 
        "[shake rate=20.0 level=5]......[/shake]", 
        "[shake rate=20.0 level=5]Be good, won't you?[/shake]", 
        "M y   c h i l d ."
    ], 
    [
        "[shake rate=20.0 level=5]You...[/shake]", 
        "[shake rate=20.0 level=5]...at my most vulnerable moment...[/shake]", 
        "[shake rate=20.0 level=5]To think I was worried you wouldn't fit in out there...[/shake]", 
        "[shake rate=20.0 level=5]Eheheheh!!! You really are no different than them![/shake]", 
        "[shake rate=20.0 level=5]Ha... ha...[/shake]"
    ], 
    [
        "[shake rate=20.0 level=5]Y... you... really hate me that much?[/shake]", 
        "[shake rate=20.0 level=5]Now I see who I was protecting by keeping you here.[/shake]", 
        "[shake rate=20.0 level=5]Not you...[/shake]", 
        "[shake rate=20.0 level=5]But them![/shake]", 
        "[shake rate=20.0 level=5]Ha... ha...[/shake]"
    ]
]

func talk(_act):
    if aggression >= 13:
        aggro_timer = 0
    await $Textbox.show_text("...", 2)

func check():
    do_check("Toriel", "Knows best for you.", 80, 80)

func damage(player_atk, left = false):
    if aggression < 13 and inv <= 0 or hp < 100 or Globals.get_flag("genocide"):
        spare_time = 100
    if super.damage(player_atk, left):
        aggression = min(aggression + 1, 24)
    aggro_timer = 0
    if boss_fight and boss_state is not PreRoaringFraud and boss_state is not SealedIdle:
        boss_state.successors = [PreRoaringFraud]

func _ready():
    super._ready()
    $Textbox.set_talk_sound(toriel_talk)
    start_pos = self.position
    initial_state = PowerfulFraud
    if aggression == 0:
        do_spare()
    if hd_remaster:
        $AnimatedSprite2D.play("hd_remaster")
        $AnimatedSprite2D.scale = Vector2(0.5, 0.5)
        death_tex = hd_death_tex

func play_animation(anim):
    if not hd_remaster:
        $AnimatedSprite2D.play(anim)
        $AnimatedSprite2D.frame = 0

func _process(delta):
    super._process(delta)
    if boss_fight:
        if target and target.hp <= 0:
            play_animation("shocked")
        aggro_timer += delta
        if aggro_timer >= (15 if target.hp > 2 or aggression < 13 else 8):

            aggro_timer = 0
            if aggression <= min_aggro:
                if aggression == 13:
                    add_spare()
                    Globals.game_manager.play_stream(end_music)
                    if boss_state is Idle or boss_state is MiniDrama:
                        boss_state = SealedIdle.new()
                    else:
                        boss_state.successors = [SealedIdle]
                    await get_tree().create_timer(4).timeout
                    aggro_timer = 0
                    boss_music = AudioStreamSelection.new()
                    boss_music.stream_group = sealed_vassal
                    boss_music.stream_mask = 1
                    Globals.game_manager.play_stream(boss_music)
                elif aggression < 13 and aggression % 2 == 1 and aggression <= min_aggro:
                    add_spare()
                    boss_music.stream_mask = sealed_masks[floor(6 - aggression * 0.5)]
                    Globals.game_manager.play_stream(boss_music)
                    get_parent().wind += 0.2
                    Globals.game_manager.find_child("MusicPlayer").set_wind(get_parent().wind)
                    if spare_time:
                        spare_time = 12
                    battle_rig.increase_drama()
                else:
                    aggression -= 1
                $Textbox.show_text(text[23 - aggression], 2)
            else:
                aggression -= 1
            min_aggro = min(min_aggro, aggression)
        if not enraged and (aggression < 20 or hp < max_hp * 0.7):
            enraged = true

class Idle extends BossState:
    var dest

    func start():
        if boss.target.hp <= 2:
            lifetime = 2
            successors = [MiniDrama]
        else:
            lifetime = 0
            successors = [ColumnSpam, ColumnSpam, BlatantlyBorrowedFromAsgore, ActualTorielAttack]
            if predecessor is not BlatantlyBorrowedFromAsgore:
                successors.append(WidowAhh)
            remove_predecessor()
        var sprite = boss.find_child("AnimatedSprite2D")
        lifetime += randf() * 0.5 + (0.0 if boss.enraged else 0.5)
        if randf() < 0.5:
            boss.play_animation("walk")
            dest = 0
            var success = false
            for i in range(8):
                if dest - boss.target.position.x > 40 and abs(boss.position.x - dest) > 20:
                    success = true
                    break
                dest = randi_range(boss.start_pos.x - 80, boss.start_pos.x)
            if not success:
                dest = boss.start_pos.x + 10
            sprite.flip_h = dest < boss.position.x
            var walk_time = abs(boss.position.x - dest) * 0.0125
            lifetime += walk_time
            var tween = boss.get_tree().create_tween()
            tween.tween_property(boss, "position", Vector2(dest, boss.position.y), walk_time)
            await tween.finished
        boss.play_animation("default" if boss.aggression > 14 else "worried")
        sprite.flip_h = true

    func process(delta):
        super.process(delta)
        if boss.target.position.x >= (dest if dest else boss.position.x) - 40:
            successors = [PreRoaringFraud]

class SealedIdle extends BossState:
    func start():
        lifetime = 1
        successors = [SealedIdle]
        var dest = boss.start_pos.x - 20
        var sprite = boss.find_child("AnimatedSprite2D")
        if boss.position.x != dest:
            sprite.flip_h = dest < boss.position.x
            var tween = boss.get_tree().create_tween()
            tween.tween_property(boss, "position", Vector2(dest, boss.position.y), abs(boss.position.x - dest) * 0.0125)
            await tween.finished
        boss.play_animation("sad" if boss.aggression > 8 else "smile" if boss.aggression > 5 else "sad" if boss.aggression > 2 else "smile")
        sprite.flip_h = true

class WidowAhh extends BossState:
    func start():
        lifetime = 0.7 if boss.enraged else 1.0
        successors = [Idle]
        boss.battle_rig.widow_ahh_telegraph()
        boss.play_animation("widow")

    func end():
        boss.battle_rig.widow_ahh()

class PreRoaringFraud extends BossState:
    func start():
        lifetime = 0.7 if boss.enraged else 1.0
        successors = [RoaringFraud]
        boss.find_child("RoaringFraudParticles").emitting = true
        boss.play_animation("focus")

class RoaringFraud extends BossState:
    func start():
        lifetime = 1
        successors = [Idle]
        boss.battle_rig.roaring_fraud(boss.position)
        boss.play_animation("scream")

class PowerfulFraud extends BossState:
    func start():
        lifetime = 3
        successors = [Idle]
        boss.battle_rig.roaring_fraud(boss.position, true)
        boss.play_animation("scream")

class ColumnSpam extends BossState:
    var on_player
    var next_attack
    var attack_gap

    func start():
        lifetime = randi_range(4, 6) + (1 if boss.enraged else 0)
        successors = [Idle]
        on_player = randf() < 0.5
        next_attack = lifetime
        attack_gap = 0.7 if boss.enraged else 1.0
        boss.play_animation("precolumn")

    func process(delta):
        super.process(delta)
        if boss.target.hp <= 2:
            while lifetime >= attack_gap:
                lifetime -= attack_gap
                next_attack -= attack_gap
        if lifetime <= next_attack and lifetime >= 1.5:
            next_attack -= attack_gap
            boss.battle_rig.spawn_column(on_player)
            on_player = not on_player
            await boss.get_tree().create_timer(1).timeout
            if boss.boss_state == self and boss.boss_fight:
                boss.play_animation("column")

class MiniDrama extends BossState:
    func start():
        lifetime = randi_range(5, 10)
        successors = [Idle]
        boss.battle_rig.mini_drama()

    func end():
        boss.battle_rig.end_drama()

class BlatantlyBorrowedFromAsgore extends BossState:
    func start():
        lifetime = 3 if boss.enraged else 4
        successors = [Idle]
        boss.battle_rig.spawn_asgore()

class ActualTorielAttack extends BossState:
    func start():
        lifetime = 3 if boss.enraged else 4
        successors = [Idle]
        boss.battle_rig.actual_toriel()
        boss.play_animation("weave")

func start_animation():
    inv = 1000
    Globals.game_manager.serious = true
    var tween = get_tree().create_tween().set_ignore_time_scale()
    tween.tween_interval(0.5)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("walk"))
    tween.tween_callback( func(): $AnimatedSprite2D.flip_h = true)
    tween.tween_property(self, "position", start_pos + Vector2.LEFT * 20, 0.25)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("default"))
    tween.tween_interval(0.5)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("walk"))
    tween.tween_callback( func(): $AnimatedSprite2D.flip_h = false)
    tween.tween_property(self, "position", start_pos, 0.25)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("default"))
    tween.tween_interval(1.5)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("walk"))
    tween.tween_callback( func(): $AnimatedSprite2D.flip_h = true)
    tween.tween_property(self, "position", start_pos + Vector2.LEFT * 80, 1)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("default"))
    tween.tween_interval(1)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("smile"))
    tween.tween_interval(3)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("walk"))
    tween.tween_callback( func(): $AnimatedSprite2D.flip_h = false)
    tween.tween_property(self, "position", start_pos + Vector2.LEFT * 40, 0.5)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("default"))
    tween.tween_interval(1)
    tween.tween_callback( func(): $AnimatedSprite2D.flip_h = true)
    tween.tween_interval(1.5)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("focus"))
    tween.tween_callback( func(): $RoaringFraudParticles.emitting = true)
    tween.tween_interval(1)
    await tween.finished
    inv = 0

func abort_fight():
    if boss_bar:
        boss_bar.discard()
    battle_rig.end_drama()
    Globals.game_manager.play_stream()
    await get_tree().create_timer(0.5).timeout
    var new_toriel = this_scene.instantiate()
    new_toriel.position = start_pos
    new_toriel.battle_rig = self.battle_rig
    var parent = get_parent()
    parent.remove_child(self)
    parent.add_child.call_deferred(new_toriel)
    new_toriel.connect("death", parent._on_toriel_death)
    new_toriel.connect("spared", parent._on_toriel_defeated)
    self.queue_free()
    Globals.game_manager.serious = false

func death_cutscene():
    battle_rig.end_drama()
    Globals.game_manager.find_child("MusicPlayer").set_wind(0)
    target.pause()
    play_animation("death")
    $AnimatedSprite2D.flip_h = false
    await get_tree().create_timer(1).timeout
    $Textbox.position.x = -20
    $Textbox.set_talk_sound(toriel_talk2)
    await $Textbox.show_text(end_text[4 if Globals.get_flag("genocide") else 3 if aggression < 13 else 2])
    await get_tree().create_timer(1).timeout
    target.unpause()
    Globals.game_manager.serious = false
    get_parent().find_child("Soul").position = self.position

func spare_cutscene():
    battle_rig.end_drama()
    Globals.game_manager.find_child("MusicPlayer").set_wind(0)
    target.pause()
    await get_tree().create_timer(1).timeout
    play_animation("worried")
    $AnimatedSprite2D.flip_h = true
    $Textbox.position.x = -10
    await $Textbox.show_text(end_text[0])
    await get_tree().create_timer(0.5).timeout
    Globals.game_manager.play_stream(fallen_down)
    play_animation("smile")
    await $Textbox.show_text(end_text[1])
    var tween = get_tree().create_tween()
    tween.tween_interval(0.5)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("smile_walk"))
    tween.tween_property(self, "position", Vector2(target.position.x, 197), abs(self.position.x - target.position.x) * 0.0125)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("smile"))
    tween.tween_interval(1)
    await tween.finished
    var sprite = target.find_child("AnimatedSprite2D")
    sprite.hide()
    target.look = "up"
    play_animation("hug")
    $AnimatedSprite2D.flip_h = false
    await get_tree().create_timer(4).timeout
    play_animation("unhug")
    await get_tree().create_timer(2).timeout
    $Textbox.position.x = 0
    await $Textbox.show_text("Goodbye, my child.")
    await get_tree().create_timer(0.5).timeout
    play_animation("smile_walk")
    $AnimatedSprite2D.flip_h = true
    sprite.show()
    tween = get_tree().create_tween()
    tween.tween_property(self, "position", Vector2(30, 197), abs(self.position.x - 30) * 0.0125)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("smile"))
    tween.tween_interval(2)
    tween.tween_callback( func(): $AnimatedSprite2D.flip_h = false)
    tween.tween_interval(3)
    tween.tween_callback( func(): $AnimatedSprite2D.flip_h = true)
    if not hd_remaster:
        tween.tween_callback( func(): $AnimatedSprite2D.play("smile_walk"))
    tween.tween_property(self, "position", Vector2(-10, 197), 0.5)
    await tween.finished
    target.unpause()
    self.hide()
    Globals.game_manager.serious = false
