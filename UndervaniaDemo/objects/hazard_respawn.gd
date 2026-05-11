extends Area2D
class_name HazardRespawn

@export var respawn_position: Vector2i

func _ready():
    self.connect("body_entered", _on_body_entered)
    self.collision_mask = 2

func _on_body_entered(body):
    if body is Player:
        body.hazard_respawn = respawn_position
