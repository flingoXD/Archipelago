extends Level

var sanctuary_guardian = preload("res://music/sanctuary guardian.wav")
var sans_font = preload("res://fonts/pixel-comic-sans-undertale-sans-font.otf")
var sans_talk = preload("res://sounds/sans_talk.wav")
var normal_font = preload("res://fonts/DeterminationMonoWebRegular-Z5oq.ttf")
var muscle = preload("res://music/muscle.wav")
var ainavol = preload("res://music/ainavol.wav")

@export var sans_limit = 370

var player
var sans_done
var jumps = 0
var jumping = false
var damaged = false

const text = [
    "you okay kid? you seemed to zone out for a sec.", 
    [
        "anyways, i bet you're wondering how i got here.", 
        "truth is, this whole room was made as a gag.", 
        "it probably wont be here in the final version, or at least i won't be.", 
        "and i won't remember ou're [color=red]conversation[/color] either.", 
        "so enjoy it while it lasts."
    ], 
    [
        "since you're here, though...", 
        "wanna help me with something?", 
        "so i've got this new attack i created.", 
        "and since we've never fought before...", 
        "why not test it out on you?", 
        "just breathe to say yes."
    ], 
    "okay then.", 
    "ready?", 
    [
        "welp.", 
        "can't blame you.", 
        "i telegraphed the attack very clearly, so of course you'd jump.", 
        "nice work, kid."
    ], 
    "...what? were you expecting something else?", 
    [
        "why didn't you jump?", 
        "come on pal, what was that [color=yellow]not-jump[/color] all about?", 
        "i made it very obvious how i was gonna attack.", 
        "but you didn't even try to avoid it.", 
        "oh, i dunno, maybe you were, like, just being [color=yellow]stupid[/color]...", 
        "or maybe, you were gonna jump...", 
        "but then you decided not to?", 
        "why would you decide not to avoid an obvious attack?", 
        "maybe you didn't want to show that you knew what my attack was?", 
        "maybe you were... [color=red]expecting something[/color]?", 
        "..."
    ], 
    [
        "wow.", 
        "you avoided the attack perfectly.", 
        "you didn't jump until just the right moment.", 
        "it's almost like you knew what was coming..."
    ], 
    "nah, i'm just messing around.", 
    "...be good, alright?", 
    [
        "anyways i gotta go now.", 
        "its my brother's bedtime.", 
        "don't worry, i know a shortcut."
    ], 
    [
        "although, by that look in your eyes...", 
        "you don't really wanna do this, do ya?", 
        "fine, i'll spare you for now."
    ]
]

func _ready():
    $Sans.hide()
    $CanvasLayer.hide()
    player = Globals.game_manager.find_child("Player")
    sans_done = 1000 if Globals.get_flag("secret_sans") else 0
    $Sans / Textbox.set_talk_font(sans_font, 14)
    $Sans / Textbox.set_talk_sound(sans_talk)

func _process(_delta):
    if player.position.x < sans_limit and sans_done == 0:
        sans_done = 1
        $Sans.show()
    if player.position.x > sans_limit and player.velocity.x == 0 and sans_done == 1:
        sans_done = 2
        start_cutscene()
    if player.jumping and not jumping:
        jumps += 1
    jumping = player.jumping

func start_cutscene():
    player.pause()
    $Sans.play("wink")
    $Sans / Label.show()
    await RenderingServer.frame_post_draw
    var screenshot = ImageTexture.create_from_image(get_viewport().get_texture().get_image())
    $CanvasLayer / TextureRect.texture = screenshot
    $CanvasLayer.show()
    get_parent().play_stream(sanctuary_guardian)
    player.position.x = 510
    $CameraLimitArea.show()
    await get_tree().create_timer(8).timeout
    $CanvasLayer.hide()
    $Sans / Label.hide()
    $Sans.play("default")
    await $Sans / Textbox.show_text(text[0])
    get_parent().play_stream(muscle)
    await $Sans / Textbox.show_text(text[1])
    await get_tree().create_timer(1).timeout
    await $Sans / Textbox.show_text(text[2])
    player.unpause()
    await get_tree().create_timer(0.5).timeout
    player.pause()
    var tween = get_tree().create_tween()
    tween.tween_interval(0.5)
    tween.tween_property($Sans, "scale", Vector2(4, 1), 1)
    await tween.finished
    $Sans.scale.x = 1
    await $Sans / Textbox.show_text(text[3])
    await get_tree().create_timer(0.5).timeout
    if Globals.get_persistent_flag("secret_sans") and not Globals.game_manager.godmode:
        await $Sans / Textbox.show_text(text[12])
    else:
        get_parent().play_stream(null, false)
        $Sans / Textbox.set_talk_font(normal_font)
        $Sans / Textbox.set_talk_sound(null)
        await $Sans / Textbox.show_text(text[4], 2)
        await get_tree().create_timer(0.5).timeout
        player.unpause()
        player.set_soul_mode(SoulMode.Blue)
        $Sans.play("eyeflash")
        await get_tree().create_timer(0.2).timeout
        $Sans.play("default")
        $BonePrep.play()
        await get_tree().create_timer(0.2).timeout
        $Warning.play()
        $BoneWarning.show()
        jumps = 0
        await get_tree().create_timer(2).timeout
        $BoneWarning.hide()
        $BoneStab.play()
        var did_you_jump = jumps
        tween = get_tree().create_tween()
        tween.tween_property($Bones, "position", Vector2(0, -40), 0.2)
        tween.tween_interval(0.1)
        tween.tween_property($Bones, "position", Vector2.ZERO, 0.2)
        tween.tween_interval(0.5)
        await tween.finished
        player.set_soul_mode(SoulMode.Red)
        player.pause()
        await get_tree().create_timer(1).timeout
        $Sans / Textbox.set_talk_font(sans_font, 14)
        $Sans / Textbox.set_talk_sound(sans_talk)
        if not did_you_jump:
            $Sans.position = Vector2(player.position.x - 20, $Sans.position.y)
            $Sans.play("dangerous")
            get_parent().play_stream(ainavol)
            $VineBoom.play()
            await $Sans / Textbox.show_text(text[7])
            await get_tree().create_timer(1).timeout
            $Sans.play("shrug")
            get_parent().play_stream(muscle)
            await $Sans / Textbox.show_text(text[9])
            await get_tree().create_timer(0.5).timeout
            $Sans.play("wink")
            await $Sans / Textbox.show_text(text[10])
        elif damaged or did_you_jump > 1:
            get_parent().play_stream(muscle)
            await $Sans / Textbox.show_text(text[5])
            await get_tree().create_timer(0.5).timeout
            $Sans.play("wink")
            await $Sans / Textbox.show_text(text[6])
        else:
            await $Sans / Textbox.show_text(text[8])
            await get_tree().create_timer(1).timeout
            $Sans.play("shrug")
            get_parent().play_stream(muscle)
            await $Sans / Textbox.show_text(text[9])
            await get_tree().create_timer(0.5).timeout
            $Sans.play("wink")
            await $Sans / Textbox.show_text(text[10])
    await get_tree().create_timer(1).timeout
    $Sans.play("default")
    await $Sans / Textbox.show_text(text[11])
    $Sans.play("walk")
    $Sans.flip_h = true
    get_tree().create_tween().tween_property($Sans, "position", Vector2(0, 207), $Sans.position.x * 0.0125)
    await get_tree().create_timer(3).timeout
    $Sans.hide()
    get_parent().play_stream()
    sans_done = 3
    Globals.set_flag("secret_sans", true)
    Globals.set_persistent_flag("secret_sans", true)
    player.unpause()
    await get_tree().create_timer(1).timeout
    $CameraLimitArea.hide()

func _on_bones_collided(body):
    if body == player:
        damaged = true
