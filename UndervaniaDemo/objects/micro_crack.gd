extends AnimatedSprite2D

var id

func _ready():
    id = int(self.animation.substr(5))
    if Globals.get_flag("micro_prog", 0) != id - 1:
        $Area2D.hide()

func _process(_delta):
    if not $Area2D.visible:
        return
    for body in $Area2D.get_overlapping_bodies():
        if body and body is Player and body.look == "up" and body.is_on_floor():
            $Area2D.hide()
            $AudioStreamPlayer.play()
            Globals.set_flag("micro_prog", id)
            if id == 5:
                await get_tree().create_timer(0.5).timeout
                $AudioStreamPlayer2.play()
