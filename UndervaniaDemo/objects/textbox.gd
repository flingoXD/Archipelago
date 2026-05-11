extends Node2D
class_name Textbox

signal _continue

func show_text(text, time = null):
    if text is Array:
        for i in text:
            await show_text(i, time)
    elif text is String:
        var parent = get_parent()
        if parent is Player:
            var camera = parent.find_child("Camera")
            global_position.x = clamp(parent.global_position.x, camera.limit_left + 160, camera.limit_right - 160)
        show()
        $RichTextLabel.text = text
        $RichTextLabel.visible_characters = 0
        if time:
            await get_tree().create_timer(time + 0.02 * len($RichTextLabel.get_parsed_text())).timeout
        else:
            await _continue
        hide()

func set_talk_sound(stream):
    $AudioStreamPlayer.stream = stream

func set_talk_font(font, size = 16):
    $RichTextLabel.add_theme_font_override("normal_font", font)
    $RichTextLabel.add_theme_font_size_override("normal_font_size", size)

func _process(_delta):
    var z_pressed = Input.is_action_just_pressed("text_enter")
    var x_pressed = Input.is_action_just_pressed("text_show")
    var c_pressed = Input.is_action_pressed("text_skip")
    if $RichTextLabel.visible_characters < len($RichTextLabel.get_parsed_text()):
        if c_pressed or x_pressed:
            $RichTextLabel.visible_characters = len($RichTextLabel.get_parsed_text())
        else:
            $RichTextLabel.visible_characters += 1
    elif c_pressed or z_pressed:
        _continue.emit()

func _on_timer_timeout():
    if $RichTextLabel.visible_characters < len($RichTextLabel.get_parsed_text()):
        $AudioStreamPlayer.play()
