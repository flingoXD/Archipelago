extends Level

var item_sfx = preload("res://sounds/item.wav")

func _ready():
    if Globals.has_ability("lantern"):
        $Area2D.hide()

func _process(_delta):
    if not $Area2D.visible:
        return
    for body in $Area2D.get_overlapping_bodies():
        if body is Player and body.look == "up":
            Globals.game_manager.ap_check_location("lantern")
            Globals.grant_ability("lantern")
            $Area2D.hide()
            body.play_sound(item_sfx)
            body.light_override = body.light_override
