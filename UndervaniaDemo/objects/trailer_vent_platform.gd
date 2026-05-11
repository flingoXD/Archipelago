



extends StaticBody2D

@export var vent_speed = 465
@export var left_enabled = false
@export var right_enabled = false

var impostor: Player
var vent_dir = 0

func _ready():
    left_enabled = left_enabled or randf() < 0.7
    if not left_enabled:
        $VentLeft.hide()
    right_enabled = right_enabled or randf() < 0.7
    if not right_enabled:
        $VentRight.hide()

func _process(_delta):
    if left_enabled:
        for node in $VentLeft.get_overlapping_bodies():
            if node is Player:
                $VentLeft / GPUParticles2D.emitting = false
                if await vent_in_electrical(node, -1):
                    $VentLeft / GPUParticles2D2.emitting = true
    if right_enabled:
        for node in $VentRight.get_overlapping_bodies():
            if node is Player:
                $VentRight / GPUParticles2D.emitting = false
                if await vent_in_electrical(node, 1):
                    $VentRight / GPUParticles2D2.emitting = true

func vent_in_electrical(player, dir):
    if impostor:
        return
    impostor = player
    player.pause()
    await get_tree().create_timer(0.5).timeout
    player.find_child("AnimatedSprite2D").play("walk")
    player.flip_h = dir < 0
    player.velocity = Vector2(player.MAX_SPEED * dir, - vent_speed)
    $AudioStreamPlayer.play()
    vent_dir = dir
    return true

func _physics_process(_delta):
    if not impostor or not vent_dir:
        return
    impostor.velocity.x = impostor.MAX_SPEED * vent_dir
    impostor.move_and_slide()
    if impostor.is_on_floor():
        impostor.unpause()
        impostor = null
        vent_dir = 0
        $VentLeft / GPUParticles2D.emitting = true
        $VentRight / GPUParticles2D.emitting = true
