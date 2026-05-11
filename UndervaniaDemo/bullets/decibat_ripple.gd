extends DamageHitbox

var SPEED = 200

var velocity = Vector2.ZERO

func _physics_process(delta):
    self.rotation = self.velocity.angle()
    self.position += self.velocity * delta
    if self.position.y > 90:
        self.velocity.y *= -1
        self.velocity = self.velocity.normalized() * SPEED
