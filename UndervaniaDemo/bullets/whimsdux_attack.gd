extends DamageHitbox

const MIN_DIST = 40

var velocity: Vector2
var accel: Vector2
var dest: Vector2
var lifetime = 1

func _ready():
    super._ready()
    if dest.distance_squared_to(self.position) < MIN_DIST ** 2:
        dest = self.position + (dest - self.position).normalized() * MIN_DIST

    velocity = (dest - self.position) * 4
    accel = - velocity * 2

func _process(delta):
    super._process(delta)
    $Sprite2D.rotate(delta * 20)
    lifetime -= delta
    if lifetime <= 0:
        self.queue_free()

func _physics_process(delta):
    velocity += accel * delta
    self.position += velocity * delta
