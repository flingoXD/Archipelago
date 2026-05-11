extends Level

var your_best_friend = preload("res://music/your best friend.wav")
var flowey_talk = preload("res://sounds/flowey_talk.wav")
var flowey_talk_evil = preload("res://sounds/flowey_talk_evil.wav")
var bullet_scene = preload("res://bullets/friendliness_pellet.tscn")
var fallen_down = preload("res://music/fallen down.wav")
var toriel_talk = preload("res://sounds/toriel_talk.wav")
var fallen_warrior = preload("res://music/fallen warrior.wav")
var shadow_amulet = preload("res://items/shadow_amulet.tres")

const text = [
    [
        "Howdy! I'm [color=yellow]FLOWEY[/color].\n[color=yellow]FLOWEY[/color] the [color=yellow]FLOWER[/color]!", 
        "Hmmm...", 
        "You've been here before, haven't you?", 
        "But not like this! I can see it in your eyes.", 
        "Golly, you must be so confused.", 
        "Someone ought to teach you how things work around here!", 
        "I guess little old me will have to do.", 
        "Ready? Here we go!"
    ], 
    [
        "See that bar? That's your HP, the very core of your being!", 
        "You start off weak and hopeless,\nbut can become stronger if you gain a lot of LV.", 
        "What's LV stand for?\nWhy, LOVE, of course!", 
        "You want some LOVE, don'tcha?", 
        "Don't worry, I'll share some with you!"
    ], 
    [
        "Down here, LOVE is shared through little white...", 
        "\"Friendliness pellets\".", 
        "Are you ready?", 
        "Move around! Get as many as you can!"
    ], 
    [
        "[shake rate=20.0 level=5]You idiot.[/shake]", 
        "[shake rate=20.0 level=5]I can't believe you fell for that.[/shake]", 
        "[shake rate=20.0 level=5]In this world, IT'S KILL OR BE KILLED.[/shake]"
    ], 
    [
        "[shake rate=20.0 level=5]You know what's going on here, don't you?[/shake]", 
        "[shake rate=20.0 level=5]You just wanted to see me suffer.[/shake]"
    ], 
    [
        "What a terrible creature, torturing such a poor, innocent youth...", 
        "Do not be afraid, my child.", 
        "I am [color=blue]TORIEL[/color], caretaker of the [color=red]RUINS[/color].", 
        "I pass through this place every day to see if anyone has fallen down.", 
        "You are the first human to come here for many years now.", 
        "Come! I shall guide you through the catacombs."
    ], 
    [
        "Howdy! I'm [color=yellow]FLOWEY[/color].\n[color=yellow]FLOWEY[/color] the [color=yellow]FLOWER[/color]!", 
        "Hee hee hee...", 
        "Why'd you make me introduce myself again?", 
        "It's rude to act like you don't know who I am.", 
        "Someone ought to teach you some proper manners.", 
        "I guess little old me will have to do.", 
        "Ready? Here we go!"
    ], 
]

const secret_text = [
    [
        "Human... I..."
    ], 
    [
        "I do not know what to say.", 
        "I have striven for so long, endangered so many.", 
        "And all for a foolish, impossible goal.", 
        "What can I do to repent for this?", 
        "I... I am so very...", 
    ], 
    [
        "Come, human. I have one small thing, the least I can give you.", 
        "I was given this amulet a long time ago by someone, I do not remember who.", 
        "But I remember there are more like it, given to others.", 
        "I know no more than this... if you want answers, seek the Mind of Patience.", 
        "He would not tell me anything, for he saw my intentions. But perhaps he will tell you.", 
        "And take this amulet. It is of no use to me any more.", 
        "But you... you are strong. You may be able to do what I cannot."
    ], 
    [
        "Goodbye, child of man. Please remember my gift, and use it well.", 
        "Seek your own path. Do not follow in mine.", 
        "With the power you have, your kindness, your perseverance, your determination...", 
        "I think you may be the one who will free us all."
    ], 
    [
        "Ah, but you carry too much on you.", 
        "Come back when you are ready to receive my gift."
    ]
]

var player
var bullets = []
var bullet_ring = -1
const BULLET_RING_SIZE = 60

signal finished_bullet_ring

func _ready():
    var strytax = Globals.get_enemy_flag("strytax")
    if Globals.get_flag("flowey1_done") or Globals.get_flag("tutoriel_prog", 0) > 0 or strytax != null:
        $CutsceneTrigger.hide()
        $Flowey.hide()
        $Toriel.hide()
    if Globals.get_flag("secret_prog", 0) < 3 or strytax != null:
        $EnemyNPC.hide()
    if strytax != false or Globals.get_flag("strytax_spare_done"):
        $CutsceneTrigger2.hide()
    if strytax != false or Globals.get_flag("strytax_spare_amulet"):
        $Strytax.hide()

func _on_cutscene_trigger_start_cutscene(p):
    player = p
    $Flowey / ArenaWalls / CollisionShape2D.set_deferred("disabled", false)
    $Flowey / ArenaWalls / CollisionShape2D2.set_deferred("disabled", false)
    get_parent().play_stream(your_best_friend)
    $Flowey / Textbox.set_talk_sound(flowey_talk)
    await get_tree().create_timer(0.5).timeout
    await $Flowey / Textbox.show_text(text[6 if Globals.get_persistent_flag("flowey_met") else 0])
    Globals.set_persistent_flag("flowey_met", true)
    Globals.set_flag("hidden_hud", false)
    await get_tree().create_timer(1).timeout
    await $Flowey / Textbox.show_text(text[1])
    $Flowey.play("wink")
    $Flowey / Sprite2D.run_animation()
    await get_tree().create_timer(2).timeout
    $Flowey.play("left")
    var tween = spawn_initial_bullets()
    await $Flowey / Textbox.show_text(text[2])
    if tween.is_running():
        await tween.finished
        await get_tree().create_timer(0.5).timeout
    activate_bullets(50, 21)
    await get_tree().create_timer(0.5).timeout
    $Flowey.play("default")
    player.unpause()
    $Timer.start()

func continue_cutscene(got_hit = false):
    $Timer.stop()
    clear_bullets()
    get_parent().play_stream(null, false)
    $Flowey / Textbox.set_talk_sound(flowey_talk_evil)
    $Flowey.play("evil")
    player.pause()
    player.velocity.x = 0
    if Globals.get_persistent_flag("flowey1_hit") == null:
        Globals.set_persistent_flag("flowey1_hit", got_hit)
    await get_tree().create_timer(1).timeout
    if got_hit:
        await $Flowey / Textbox.show_text(text[3])
    else:
        await $Flowey / Textbox.show_text(text[4])
    await spawn_bullet_ring()
    await get_tree().create_timer(0.5).timeout
    $Flowey / DIE.show()
    await get_tree().create_timer(1).timeout
    $Flowey / DIE.hide()
    $Flowey.offset.y = -19.5
    $Flowey.play("grow")
    await $Flowey.animation_finished
    $Flowey.play("laugh")
    $Flowey / Laugh.play()
    activate_bullets(6)
    player.unpause()
    $Timer2.start()

func _process(_delta):
    for area in $Flowey / Area2D.get_overlapping_areas():
        if area.visible and area.get_parent() is Player and not $Timer.is_stopped():
            continue_cutscene()
    if bullet_ring >= BULLET_RING_SIZE:
        bullet_ring = -1
        finished_bullet_ring.emit()
    elif bullet_ring >= 0:
        var bullet = bullet_scene.instantiate()
        add_child(bullet)
        var rot = 2 * PI * bullet_ring / BULLET_RING_SIZE
        bullet.position = player.position + Vector2(sin(rot), - cos(rot)) * 60
        bullets.append(bullet)
        bullet_ring += 1

func spawn_initial_bullets():
    var tween = get_tree().create_tween().set_parallel()
    for i in range(5):
        var bullet = bullet_scene.instantiate()
        $Flowey.add_child(bullet)
        var rot = (1.25 + i * 0.125) * PI
        tween.tween_property(bullet, "position", Vector2(cos(rot), sin(rot)) * 120, 1)
        bullets.append(bullet)
    return tween

func spawn_bullet_ring():
    bullet_ring = 0
    await finished_bullet_ring

func activate_bullets(speed, atk = null):
    for bullet in bullets:
        bullet.velocity = (player.global_position - bullet.global_position).normalized() * speed
        bullet.atk = atk
        bullet.active = true
        bullet.connect("hit_player", _on_hit_player)

func clear_bullets():
    for bullet in bullets:
        bullet.queue_free()
    bullets = []

func _on_hit_player():
    if not $Timer.is_stopped():
        continue_cutscene(true)
    elif not $Timer2.is_stopped():
        finish_cutscene()

func finish_cutscene():
    var hd_remaster = Globals.get_persistent_flag("silly_shader") == "hd_remaster"
    $Timer2.stop()
    clear_bullets()
    player.heal(1000)
    $Flowey / Laugh.stop()
    $Flowey.play("shrink")
    player.pause()
    player.velocity.x = 0
    await $Flowey.animation_finished
    $Flowey.offset.y = 0
    $Flowey.play("look_right")
    $Flowey / ArenaWalls / CollisionShape2D.set_deferred("disabled", true)
    $Flowey / ArenaWalls / CollisionShape2D2.set_deferred("disabled", true)
    if hd_remaster:
        $Toriel.hide()
        $Toriel.play("hd_remaster")
        $Toriel.scale = Vector2(0.5, 0.5)
        $Toriel / Textbox.position *= 2
        $Toriel / Textbox.scale *= 2
    await yeet_flowey(hd_remaster)
    if not hd_remaster:
        $Toriel.play("default")
    await get_tree().create_timer(0.5).timeout
    get_parent().play_stream(fallen_down)
    $Toriel / Textbox.set_talk_sound(toriel_talk)
    await $Toriel / Textbox.show_text(text[5])
    $Toriel.flip_h = false
    if not hd_remaster:
        $Toriel.play("walk")
    var tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(480, 97), 0.5)
    await tween.finished
    Globals.set_flag("flowey1_done", true)
    $Toriel.hide()
    $Flowey.hide()
    player.unpause()

func yeet_flowey(hd_remaster):
    $TorielFire.show()
    $TorielFire.play("default")
    await get_tree().create_timer(1).timeout
    var tween = get_tree().create_tween()
    tween.tween_property($TorielFire, "position", Vector2(320, 112), 0.5)
    tween.tween_callback($TorielFire.hide)
    tween.tween_callback( func(): $Flowey.play("shocked"))
    tween.tween_callback($Flowey / Yelp.play)
    tween.tween_property($Flowey, "position", Vector2(100, 40), 1)
    tween.set_parallel()
    tween.tween_property($Flowey, "rotation", - PI, 1)
    tween.set_parallel(false)
    tween.tween_callback( func():
        if hd_remaster:
            $Toriel.show()
        else:
            $Toriel.play("walk")
    )
    tween.tween_property($Toriel, "position", Vector2(420, 97), 0.5)
    await tween.finished

func _on_cutscene_trigger2_start_cutscene(p):
    player = p
    await $Strytax / Textbox.show_text(secret_text[0])
    await get_tree().create_timer(1).timeout
    $Strytax.play("kneel")
    $Strytax.flip_h = true
    $Strytax.position.y += 12.5
    get_parent().play_stream(fallen_warrior)
    await get_tree().create_timer(2).timeout
    await $Strytax / Textbox.show_text(secret_text[1])
    await get_tree().create_timer(1).timeout
    await $Strytax / Textbox.show_text(secret_text[2])
    var received = Globals.game_manager.ap_check_location(shadow_amulet.item_id)
    await get_tree().create_timer(1).timeout
    await $Strytax / Textbox.show_text(secret_text[3 if received else 4])
    await get_tree().create_timer(0.5).timeout
    player.unpause()
    Globals.set_flag("strytax_spare_done", true)
    Globals.set_flag("strytax_spare_amulet", received)
