extends DamageHitbox

const GRAVITY = -200
const TIME = 1

var velocity
var lifetime = 2

func _process(delta):
    super._process(delta)
    $AnimatedSprite2D.flip_h = self.velocity.x < 0
    lifetime -= delta
    if lifetime <= 0:
        self.queue_free()

func _physics_process(delta):
    velocity.y += GRAVITY * delta
    self.position += velocity * delta
