extends DamageHitbox

const SPEED = 120

var flip_frames = 0
var lifetime = 10
var rot_cooldown = 0.2
@onready var rot = PI * 0.5 if randf() < 0.5 else - PI * 0.5
var target
var arena_rect = Rect2i(30, 30, 260, 200)

func _process(delta):
    lifetime -= delta
    super._process(delta)
    flip_frames -= delta
    if flip_frames <= 0:
        flip_frames = 0.1
        $Sprite2D.flip_h = not $Sprite2D.flip_h

func _physics_process(delta):
    rot_cooldown -= delta
    if rot_cooldown <= 0 and not arena_rect.has_point(self.position):
        if self.rotation == 0 and lifetime <= 0:
            self.queue_free()
            return
        self.position.x = clamp(self.position.x, arena_rect.position.x, arena_rect.end.x - 1)
        self.position.y = clamp(self.position.y, arena_rect.position.y, arena_rect.end.y - 1)
        self.rotation += rot
        rot_cooldown = 0.2
    elif target.position.y > self.position.y and abs(self.position.x - target.position.x) < 5 and self.rotation != 0:
        self.rotation = 0
        rot_cooldown = 0.2
    self.position += Vector2(sin(self.rotation), cos(self.rotation)) * SPEED * delta
