extends Label
class_name Numbers

const SPEED = 10

func _process(delta):
    self.position.y -= SPEED * delta
    self.modulate.a -= delta
    if self.modulate.a <= 0:
        self.queue_free()
