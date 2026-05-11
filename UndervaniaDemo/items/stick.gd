extends RigidBody2D

@export var stick: Item

var lifetime = 0

func _ready():
    self.linear_velocity = Vector2(1, -1) * 300
    self.angular_velocity = 10
    self.rotation = randf_range(0, 2 * PI)

func _process(delta):
    lifetime += delta

func _on_body_entered(body):
    if body is Player and lifetime > 0.5:
        queue_free()
