extends Area2D
class_name Hazard

@export var atk = 6

func _ready():
    self.collision_layer = 2
    self.collision_mask = 2
    self.connect("body_entered", _on_body_entered)

func _on_body_entered(body):
    if not self.visible:
        return
    if body is Player:
        body.damage(atk)
        body.get_parent().hazard_respawn()
    elif body is Enemy and body.inv <= 0:
        body.call_deferred("do_flee", true)
