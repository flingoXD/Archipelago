extends Sprite2D
class_name DeathParticle

var velocity
var tex = preload("res://sprites/pixel.png")
var countdown = 0

func _ready():
    velocity = Vector2(randf_range(-1.5, 1.5), randf_range(-2, -1)) * 8
    self.texture = tex

func _process(delta):
    if countdown > 0:
        countdown -= delta
        return
    self.position += velocity * delta
    self.modulate.a -= delta
    if self.modulate.a <= 0:
        self.queue_free()
