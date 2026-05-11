extends Area2D
class_name Sign

@export var text: Array[String]

var showing = false

func _ready():
    self.collision_mask = 2

func _process(_delta):
    if not self.visible:
        return
    for body in self.get_overlapping_bodies():
        if body and body is Player:
            if body.look == "up" and not body.flip_h and body.is_on_floor() and not showing:
                showing = true
                body.pause()
                await body.find_child("Textbox").show_text(text)
                await get_tree().create_timer(0.5).timeout
                body.unpause()
            elif body.look != "up" and showing:
                showing = false
