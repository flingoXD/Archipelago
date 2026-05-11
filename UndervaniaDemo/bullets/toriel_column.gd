extends Node2D

const COLUMN_SPEED = 1000
const COLUMN_LEN = 0.8

var battle_rig
var column_timer = 0
var player
var quitting = false

func _ready():
    battle_rig = get_parent()
    $GPUParticles2D.emitting = true
    column_timer = 1

func _process(delta):
    column_timer -= delta









    if player:
        $Hitbox.atk = ceil(3 + 5 * player.hp / player.max_hp)
        if player.hp <= 2:
            if column_timer > 0:
                column_timer = -2
            elif not quitting:
                quitting = true
                $Hitbox.collision_mask = 0
                $Hitbox.hide()
                if column_timer > - COLUMN_LEN:
                    $GPUParticles2D2.hide()
                    $GPUParticles2D.emitting = true
    if column_timer <= -2:
        queue_free()
    elif column_timer <= - COLUMN_LEN:
        if $GPUParticles2D2.emitting:
            $GPUParticles2D2.emitting = false
        $Hitbox / Shape.shape.size.y = max($Hitbox / Shape.shape.size.y - COLUMN_SPEED * delta, 0)
        $Hitbox / Shape.position.y = min($Hitbox / Shape.position.y + COLUMN_SPEED * delta * 0.5, 120)
    elif column_timer <= 0:
        Globals.game_manager.camera_shake(2)
        if not $GPUParticles2D2.emitting:
            $GPUParticles2D2.emitting = true
            $AudioStreamPlayer.pitch_scale = randf_range(0.6, 1)
            $AudioStreamPlayer.play()
        $Hitbox / Shape.shape.size.y = min($Hitbox / Shape.shape.size.y + COLUMN_SPEED * delta, 240)
        $Hitbox / Shape.position.y = min($Hitbox / Shape.position.y + COLUMN_SPEED * delta * 0.5, 0)
