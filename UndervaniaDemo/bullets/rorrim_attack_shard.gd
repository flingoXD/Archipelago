extends DamageHitbox

var _gravity = 300
var velocity = Vector2.ZERO

func _ready():
    super._ready()
    velocity = Vector2(randi_range(-60, 60), -160)


func _physics_process(delta):
    velocity.y += _gravity * delta
    self.position += velocity * delta
