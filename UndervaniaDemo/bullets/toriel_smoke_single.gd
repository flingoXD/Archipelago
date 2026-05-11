extends Sprite2D

var velocity
@onready var time = 1 - randf() * 0.5

func _physics_process(delta):
    self.position += velocity * delta
    time -= delta
    if time <= 0:
        self.queue_free()
