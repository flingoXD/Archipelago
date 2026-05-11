extends Sprite2D
class_name LightBox

@export var neighbors: Array[LightBox]

var mutable = true
@export var active = false:
    set(val):
        active = val
        $PointLight2D.enabled = active
        self.texture = box_on if active else box_off

var box_on = preload("res://sprites/box_on.png")
var box_off = preload("res://sprites/box_off.png")

func _process(_delta):
    if not mutable:
        return
    for body in $Area2D.get_overlapping_bodies():
        if body is Player and abs(body.position.x - self.position.x) < 10 and Input.is_action_just_pressed("up"):
            active = not active
            for node in neighbors:
                node.active = not node.active
            $AudioStreamPlayer.play()
