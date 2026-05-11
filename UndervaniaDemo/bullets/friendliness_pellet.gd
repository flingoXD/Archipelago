extends Area2D

var atk = 0
var active = false
var velocity = Vector2.ZERO

signal hit_player

func _ready():
    $AnimatedSprite2D.play("default")

func _on_body_entered(body):
    if body is Player and active:
        if atk:
            body.damage(atk, body.global_position.x < self.global_position.x)
        hit_player.emit()
        self.queue_free()

func _physics_process(delta):
    self.position += velocity * delta
