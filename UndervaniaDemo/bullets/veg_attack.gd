extends RigidBody2D

var atk = 5
var expiring = false
var green = false:
    set(val):
        green = val
        self.modulate = Color.GREEN if val else Color.WHITE
        $CollisionShape2D.scale = Vector2(2, 2) if val else Vector2(1, 1)
var source
var physical = true

@onready var player = Globals.game_manager.find_child("Player")

func _ready():
    $Sprite2D.texture.region.position = Vector2(randi_range(0, 1) * 24, randi_range(0, 2) * 24)

func _process(_delta):
    if player.can_parry(self):
        self.queue_free()

func _on_body_entered(body):
    if body is Player:
        if body.can_parry(self, true):
            body.parry()
            self.queue_free()
        elif green:
            body.heal(1)
            if source:
                source.eat_greens()
        else:
            body.damage(atk, body.global_position.x < self.global_position.x)
        self.queue_free()
    elif expiring:
        self.queue_free()

func _on_timer_timeout():
    expiring = true
