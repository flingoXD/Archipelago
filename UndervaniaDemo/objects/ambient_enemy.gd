extends CharacterBody2D
class_name AmbientEnemy

enum MOVE_MODE{GROUND, LAUNCH, FLYING}

const GRAVITY = 960

@export var move_mode: MOVE_MODE
@export var speed: float = 200
@export var detection: Area2D

var target
var xvel = 0

func _ready():
    collision_layer = 2
    speed *= randf_range(0.8, 1.2)
    if detection:
        detection.connect("body_entered", _on_detection_body_entered)

func _process(_delta):
    if self.velocity.x == 0:
        $AnimatedSprite2D.play("default")
    else:
        $AnimatedSprite2D.play("move")

func _physics_process(delta):
    if is_on_wall():
        xvel = - xvel
    self.velocity.x = xvel
    match move_mode:
        MOVE_MODE.GROUND:
            self.velocity.y += GRAVITY * delta
            if randf() < 0.02 and target and is_on_floor():
                self.velocity.y = -150
        MOVE_MODE.LAUNCH:
            self.velocity.y -= GRAVITY * delta
        MOVE_MODE.FLYING:
            self.velocity = target.position.direction_to(self.position) * speed if target else Vector2.ZERO
    move_and_slide()

func _on_detection_body_entered(body):
    if body is Player:
        target = body
        do_flee()

func do_flee():
    match move_mode:
        MOVE_MODE.GROUND:
            xvel = speed * sign(self.position.x - target.position.x) * (-1 if randf() < 0.3 else 1)
        MOVE_MODE.LAUNCH:
            xvel = speed * sign(self.position.x - target.position.x)
    var tween = get_tree().create_tween()
    tween.tween_interval(1)
    tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
    await tween.finished
    self.queue_free()
