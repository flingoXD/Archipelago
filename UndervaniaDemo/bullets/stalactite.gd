extends DamageHitbox

var impact_sfx = preload("res://sounds/impact.wav")

const GRAVITY = 300
var speed = 0
var falling = false

func _process(delta):
    super._process(delta)
    var target = $RayCast2D.get_collider()
    if target and not falling and (target is Player or target is Enemy):
        falling = true
        $AudioStreamPlayer.play()

func _physics_process(delta):
    if not falling:
        return
    speed += GRAVITY * delta
    self.position.y += speed * delta

func _on_collided(body):
    if body is Boss:
        return
    elif body is Enemy and body.inv <= 0:
        body.call_deferred("do_flee", true)
        self.queue_free()
    var audio = AudioStreamPlayer.new()
    add_sibling(audio)
    audio.stream = impact_sfx
    audio.play()
