extends RigidBody2D

func _process(_delta):
    if not self.visible:
        return
    for body in $Area2D.get_overlapping_bodies():
        if body is Player:
            body.earn_gold(1)
            self.queue_free()
