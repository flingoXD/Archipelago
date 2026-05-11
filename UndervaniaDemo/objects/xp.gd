extends CharacterBody2D

var target
var big = false

func _ready():
    if big:
        self.scale = Vector2(2, 2)

func _process(_delta):
    if not $Sprite2D.visible:
        return
    for body in $Area2D.get_overlapping_bodies():
        if body is Player:
            body.xp += 10 if big else 1
            $Sprite2D.hide()
            $GPUParticles2D.emitting = false
            await get_tree().create_timer(1).timeout
            self.queue_free()
    if not target:
        for body in $DetectionRange.get_overlapping_bodies():
            if body is Player:
                target = body

func _physics_process(_delta):
    if target:
        var target_vel = (target.global_position - self.global_position).normalized() * 300
        self.velocity = self.velocity * 0.8 + target_vel * 0.2
    else:
        self.velocity *= 0.8
    move_and_slide()
