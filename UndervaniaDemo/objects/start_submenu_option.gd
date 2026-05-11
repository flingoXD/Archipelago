extends Label

@export var neighbor_left: Control
@export var neighbor_right: Control
@export var neighbor_up: Control
@export var neighbor_down: Control

signal selected

func select():
    $TextureRect.show()
    $AudioStreamPlayer.play()

func _process(_delta):
    if not $TextureRect.visible:
        return
    if Input.is_action_just_pressed("text_enter"):
        $AudioStreamPlayer2.play()
        selected.emit()
        return
    for dir in ["left", "right", "up", "down"]:
        if Input.is_action_just_pressed(dir) and get("neighbor_" + dir):
            $TextureRect.hide()
            await get_tree().create_timer(0.01).timeout
            get("neighbor_" + dir).select()
            return
