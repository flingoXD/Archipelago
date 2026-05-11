extends Level

var strytax_talk = preload("res://sounds/strytax_talk.wav")
var strytax_talk2 = preload("res://sounds/strytax_talk2.wav")
var arrow_sfx = preload("res://sounds/arrow.wav")
var cymbal_sfx = preload("res://sounds/cymbal.wav")
var giygas_sfx = preload("res://sounds/giygas.wav")
var barrier = preload("res://music/barrier.wav")

var hidden_platforms = []

const text = [
    [
        "...so you finally came.", 
        "I should have brought you here myself, but I was not armored.", 
        "I could not risk being attacked by you prematurely.", 
        "And of course, the location was vitally important.", 
        "Let me explain why I have summoned you here."
    ], 
    [
        "The old grave which you passed on the way here lies at the bottom of this tall chasm.", 
        "If you look closely, you can almost see the light of the surface, shining at the very top.", 
        "But you know that already, of course.", 
        "This is where you entered the Underground.", 
        "You and every human before you, ever since the Underground was sealed.", 
        "Sealed by a great barrier, apparently impossible to cross.", 
        "But then what of this shaft from which the humans come?", 
        "This elusive, high exit, this second way out?", 
        "I've told people of it, time and time again!", 
        "There is a second way, I tell them.\nA way the humans overlooked.", 
        "We don't have to amass all this power to break the barrier, or just accept our fates.", 
        "We can fly up this shaft and escape, and open the barrier from the other side.", 
        "Look at where that got me!", 
        "I was a great fighter in the War, yet they called me a fool, and discharged me from the Royal Guard.", 
        "Why can't anyone see it? Am I really the only one to have thought of this?", 
    ], 
    [

        "That is why I came back here to the Ruins.", 
        "If nobody will listen, I shall do it myself.", 
        "I cannot fly, of course, and the Fliers and Whimsduces will not listen to me.", 
        "I can climb up some distance, but the dirt is too loose to get a grip.", 
        "Platforms just crumple under their own weight.", 
        "Grappling hooks fall back down without taking hold.", 
        "I have tried and failed, so many times, so many ways.", 
        "There is only one way left - a power so great, it has to work, it cannot fail.", 
    ], 
    [
        "A shame... I was beginning to like you. Heh."
    ], 
    [
        "But I feel no regret - not after what you've done.", 
        "Toriel was always a good person, even when the others mocked me, and I think she believed me, at least in part.", 
        "You have taken a great shining light out of the world today, and you will pay for it!"
    ], 
    [
        "Before you die, witness what remains of my power!", 
        "I am no weak-minded fool! I will not be stopped!", 
        "I am Strytax, the Sword of Perseverance!", 
        "And with the power of your soul, I will be vindicated!"
    ]
]

func _ready():
    var prog = Globals.get_flag("secret_prog")
    if prog == 2:
        $StrytaxNPC.hide()
        $CutsceneTrigger.hide()
    var strytax = Globals.get_enemy_flag("strytax")
    if strytax != null:
        $StrytaxNPC.hide()
        $CutsceneTrigger.hide()
        $CutsceneTrigger2.hide()
    else:
        $CameraLimitArea2.hide()
        for i in range(6):
            var platform = $Rubble.find_child("BrokenPlatform" + str(i + 1))
            hidden_platforms.append(platform)
            $Rubble.remove_child(platform)
    $ClingSpots.hide()
    if has_node("ItemCollect"):
        if not strytax:
            $ItemCollect.hide()
        $ItemCollect.item = $Strytax.shadow_amulet

func _on_cutscene_trigger_start_cutscene(player):
    $CameraLimitArea.show()
    $Textbox.set_talk_sound(strytax_talk)
    get_tree().create_tween().tween_property($GodRays / Spotlight, "modulate", Color.WHITE, 5)
    await get_tree().create_timer(1).timeout
    if not Globals.get_persistent_flag("strytax_encountered"):
        await $Textbox.show_text(text[0])
        $StrytaxNPC.flip_h = false
        await get_tree().create_timer(0.5).timeout
        await $Textbox.show_text(text[1])
        await get_tree().create_timer(0.5).timeout
        $StrytaxNPC.flip_h = true
        await get_tree().create_timer(0.5).timeout
        await $Textbox.show_text(text[2])
        $StrytaxNPC.flip_h = false
        await get_tree().create_timer(0.5).timeout
        await $Textbox.show_text(text[3])
    $StrytaxNPC.flip_h = false
    $StrytaxNPC.position.y = 178
    $StrytaxNPC.play("sword_draw")
    await get_tree().create_timer(1).timeout
    $Textbox.set_talk_sound(strytax_talk2)
    await $Textbox.show_text(text[5])
    await get_tree().create_timer(0.5).timeout
    player.unpause()
    $CameraLimitArea.hide()
    get_tree().create_tween().tween_property($GodRays / Spotlight, "modulate", Color.TRANSPARENT, 5)
    $Scabbard.show()
    $StrytaxNPC.hide()
    $Strytax.start_fight()
    $Hazard.show()
    $InteractDoor2.hide()
    $StaticBody2D / CollisionShape2D.set_deferred("disabled", false)
    Globals.set_persistent_flag("strytax_encountered", true)

func spawn_platforms():
    if len(hidden_platforms) == 0:
        return
    $CameraLimitArea2.show()
    for platform in hidden_platforms:
        platform.find_child("Sprites").hide()
        platform.collision_layer = 0
        $Rubble.add_child(platform)
        platform._on_timer_timeout()
        await get_tree().create_timer(0.2).timeout
    hidden_platforms = []
    Globals.set_flag("secret_chasm_done", true)

func _on_cutscene_trigger2_start_cutscene(_player):
    while not is_instance_of($Strytax.boss_state, $Strytax.WallCling):
        await get_tree().create_timer(0.2).timeout
    $Strytax.start_third_phase()
    $CameraLimitArea3.limit_bottom = -4720
    $Hazard2.show()

func _on_strytax_death(_spare = false):
    if not $ItemCollect.visible:
        Globals.set_flag($ItemCollect.collect_id, true)
    await get_tree().create_timer(3).timeout
    $CameraLimitArea3.limit_bottom = null
    $Hazard.hide()
    $Hazard2.hide()
    $InteractDoor2.show()
    $StaticBody2D / CollisionShape2D.set_deferred("disabled", true)
    await get_tree().create_timer(2).timeout
    Globals.game_manager.play_stream()







func _on_strytax_spared():
    _on_strytax_death(true)

func barrier_cutscene():
    var player = get_parent().find_child("Player")
    var rendezvous = Vector2(($Strytax.position.x + player.position.x) * 0.5, -2480)
    $Strytax.play_animation("spin_jump")
    $Strytax.flip_h = player.position.x < $Strytax.position.x
    player.flip_h = player.position.x > $Strytax.position.x
    var tween = get_tree().create_tween().set_parallel()
    tween.tween_property($Strytax, "position", rendezvous, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
    tween.tween_property($Strytax, "rotation", $Strytax.rotation + 30 * (-1 if $Strytax.flip_h else 1), 1)
    tween.tween_property(player, "position", rendezvous, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
    await tween.finished
    $Strytax.play_animation("infinity")
    $Strytax.rotation = - PI * 0.5
    $Strytax.play_sound(arrow_sfx)
    $Strytax.play_sound(cymbal_sfx)
    player.velocity = Vector2.ZERO
    var time = cymbal_sfx.get_length()
    var old_limit = $CameraLimitArea3.limit_bottom
    tween = get_tree().create_tween().set_parallel()
    tween.tween_property($Strytax, "position", Vector2(rendezvous.x, -2650), time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
    tween.tween_property($CameraLimitArea3, "limit_bottom", -4920, time)
    tween.tween_property($EscapeLight, "modulate", Color.WHITE, time)
    await tween.finished
    $Strytax.play_sound(giygas_sfx)
    $Strytax.play_animation("zap")
    await get_tree().create_timer(giygas_sfx.get_length()).timeout
    $CameraLimitArea3.limit_bottom = old_limit
    $GodRays2.hide()
    $Parallax2D2 / Barrier.show()
    get_parent().play_stream(barrier)
    get_tree().create_tween().tween_property($EscapeLight, "modulate", Color.TRANSPARENT, 2)

func spawn_amulet():
    $ItemCollect.item = $Strytax.shadow_amulet
    $ItemCollect.position.x = $Strytax.position.x
    $ItemCollect.show()

func _process(_delta):
    if Globals.game_manager.godmode and has_node("Strytax") and $Strytax.phase == 2 and Input.is_action_just_pressed("act3"):
        Globals.game_manager.find_child("Player").position = Vector2(160, -2420)
