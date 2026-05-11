extends AnimatedSprite2D

func _ready():
    animation = "empty"
    await get_tree().create_timer(0.1).timeout
    if $VisibleOnScreenNotifier2D.is_on_screen():
        queue_free()
    else:
        animation = "sink"
    await get_tree().create_timer(30).timeout
    if not is_playing():
        queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered():
    if animation == "sink":
        play("sink")
        await animation_finished
        queue_free()
