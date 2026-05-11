extends Item

var not_punchcard_scene = preload("res://items/not_punchcard.tscn")

signal continued

func on_use(player):
    super.on_use(player)
    var not_punchcard = not_punchcard_scene.instantiate()
    player.add_child(not_punchcard)
    await continued
    not_punchcard.queue_free()
    var tween = player.get_tree().create_tween()
    tween.tween_interval(0.5)
    tween.tween_callback(player.unpause)
    return false

func on_process(_delta):
    if Input.is_action_just_pressed("text_enter"):
        continued.emit()
