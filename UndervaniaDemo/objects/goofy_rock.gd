extends CharacterBody2D

@export var lock_x = 0

signal lock
var locked

func _physics_process(_delta):
    if abs(self.position.x - lock_x) < 2 and not locked:
        self.position.x = lock_x
        $AudioStreamPlayer.play()
        locked = true
        lock.emit()
    if locked:
        return
    self.velocity = Vector2.ZERO
    for body in $Area2D.get_overlapping_bodies():
        if body is Player:
            self.velocity.x = sign(self.position.x - body.position.x) * 200
    move_and_slide()
    self.position.x = round(self.position.x * 2) * 0.5
