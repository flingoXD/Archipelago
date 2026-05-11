extends Label

@export var neighbor_left: Control
@export var neighbor_right: Control
@export var neighbor_up: Control
@export var neighbor_down: Control

var item: Item:
    set(val):
        item = val
        self.text = item.get_nickname(Globals.game_manager.serious) if item else "..."

func select():
    $TextureRect.show()
    $AudioStreamPlayer.play()

func _process(_delta):
    if $TextureRect.visible:
        if Input.is_action_just_pressed("text_enter") and item:
            $AudioStreamPlayer2.play()
            $TextureRect.hide()
            get_parent().get_parent().selected.emit(item)
        elif Input.is_action_just_pressed("text_show"):
            $TextureRect.hide()
            get_parent().get_parent().selected.emit(null)
        for dir in ["left", "right", "up", "down"]:
            if Input.is_action_just_pressed(dir) and get("neighbor_" + dir):
                $TextureRect.hide()
                await get_tree().create_timer(0.01).timeout
                get("neighbor_" + dir).select()
                return
