extends DamageHitbox

const SPEED = 120
const Y_LIMIT = 220

var velocity = Vector2.ZERO
var acceleration = Vector2(0, 1)

func _ready():
    var s = randf_range(0.7, 1)
    self.scale = Vector2(s, s)

func _physics_process(delta):
    if self.position.y > Y_LIMIT:
        self.queue_free()
        return
    velocity = (velocity + acceleration).normalized() * SPEED
    self.rotation = velocity.angle() - PI * 0.5
    self.position += velocity * delta
