extends Control

signal _continue

const dialogue = {
    "talk": [
        "You consider sending a check to the Multiworld instead...", 
        "You sent a check."
    ],
    "cheer": [
        [
            "From this high vantage point, you can see beyond the RUINS, into the snow-covered forests beyond.", 
            "You feel a strange urge to send a check."
        ], 
        "You sent a check."
    ],
    "glide": [
        [
            "It's a discarded check from another World.", 
            "You wonder if you can find a way to send it..."
        ], 
        "You sent a check."
    ], 
    "check": [
        [
            "You look in the Undervania Demo Client, and ponder your checks.", 
            "You wonder if it's possible to send another..."
        ], 
        "You sent a check."
    ], 
    "threat": [
        [
            "Standing at the top of the tower, you look out across the halls and towers of the RUINS.",
            "You feel overwhelming confidence that you won't be BK'd."
        ],
        "You sent a check."
    ]
}

var move_desc = {
    "glide": func(key): return "You received the Bat Wings! Press and hold " + key + " while in midair to glide."
}

func sleep(time):
    await get_tree().create_timer(time).timeout

func run(ability, flag = null):
    show()
    await show_text(dialogue[ability][0] if flag == null else "You have the sense that someone has sent you something important.")
    await sleep(1)
    $Gaining.play()
    await show_text("You're filled with DETERMINATION.", 5)
    await sleep(1)
    $AnimatedSprite2D.play(ability)
    var tween = get_tree().create_tween()
    tween.tween_property($AnimatedSprite2D, "modulate", Color.WHITE, 1)
    await tween.finished
    $Gained.volume_db = -5
    $Gained.play()
    if flag:
        if ability in Globals.acts:
            await show_text("You received a new ACT!\nPress " + Globals.get_key_name(Globals.input_keys[ability]) + " to " + ability + ".")
        elif ability in Globals.moves:
            await show_text(move_desc[ability].call(Globals.get_key_name(Globals.input_keys[ability])))
    else: await show_text(dialogue[ability][1])
    tween = get_tree().create_tween().set_parallel()
    tween.tween_property($AnimatedSprite2D, "modulate", Color.TRANSPARENT, 1)
    tween.tween_property($Gained, "volume_db", -40, 1)
    await tween.finished
    $Gained.stop()
    hide()

func show_text(text, time = null):
    if text is Array:
        for i in text:
            await show_text(i, time)
    else:
        $Label.show()
        $Label.text = "* " + text
        $Label.visible_characters = 2
        if time:
            await get_tree().create_timer(time).timeout
        else:
            await _continue
        $Label.hide()

func _process(_delta):
    var z_pressed = Input.is_action_just_pressed("text_enter")
    var x_pressed = Input.is_action_just_pressed("text_show")
    var c_pressed = Input.is_action_pressed("text_skip")
    if $Label.visible_characters < len($Label.text):
        if c_pressed or x_pressed:
            $Label.visible_characters = len($Label.text)
        else:
            $Label.visible_characters += 1
    elif c_pressed or z_pressed:
        _continue.emit()

func _on_timer_timeout():
    if $Label.visible_characters < len($Label.text):
        $TalkSound.play()

func intro_text(text, time):
    $Label.show()
    $Label.modulate = Color.WHITE
    $Label.text = text
    $Label.visible_characters = 2
    await sleep(time)
    get_tree().create_tween().tween_property($Label, "modulate", Color.TRANSPARENT, 1)
    await sleep(1)
    $Label.modulate = Color.WHITE

func intro_fade(anim, time):
    $AnimatedSprite2D2.play(anim)
    var tween = get_tree().create_tween()
    tween.tween_property($AnimatedSprite2D2, "modulate", Color.WHITE, 1)
    tween.tween_interval(time - 1)
    tween.tween_property($AnimatedSprite2D2, "modulate", Color.TRANSPARENT, 1)
    await tween.finished

func intro():
    $Label.position = Vector2(40, 343.5)
    show()
    await sleep(1)
    intro_text("Long ago, two races ruled over the earth: HUMANS and MONSTERS.", 6)
    await intro_fade("intro1", 6)
    intro_text("One day, war broke out between the two races.", 6)
    await intro_fade("intro2", 6)
    intro_text("After a long and bloody struggle, the humans had the victory.", 6)
    await intro_fade("intro3", 6)
    intro_text("They sealed the monsters away underground, with a magical barrier.", 6)
    await intro_fade("intro4", 6)
    await intro_text("Many years later...", 3)
    intro_text("Mount Ebott, 201X.", 6)
    await intro_fade("intro5", 6)
    intro_text("Legends say that those who climb the mountain never return.", 6)
    await intro_fade("intro6", 6)
    $Label.hide()
    await intro_fade("intro7", 5)
    await intro_fade("intro8", 5)
    await intro_fade("intro9", 5)
    $ColorRect.show()
    $Sprite2D.show()
    $Sprite2D.modulate = Color.TRANSPARENT
    var tween = get_tree().create_tween()
    tween.tween_property($Sprite2D, "modulate", Color.WHITE, 1)
    tween.tween_interval(3)
    tween.tween_property($Sprite2D, "position", Vector2(320, 406), 12)
    tween.tween_interval(8)
    tween.tween_property($Sprite2D, "modulate", Color.TRANSPARENT, 8)
    await tween.finished
