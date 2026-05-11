extends StaticBody2D

enum PLATFORM_TYPE{RUINS, RUBBLE}
@export var platform_type = PLATFORM_TYPE.RUINS

var shake = false
const SHAKE_INTENSITY = 2

func _ready():
    for node in $Sprites.get_children():
        node.hide()
    match platform_type:
        PLATFORM_TYPE.RUINS:
            $Sprites / Ruins1.show()
            $Sprites / Ruins2.show()
            $Sprites / Ruins3.show()
        PLATFORM_TYPE.RUBBLE:
            $Sprites / Rubble1.show()
            $Sprites / Rubble2.show()

func _on_timer_timeout():
    shake = false
    if $Sprites.visible:
        $Sprites.hide()
        self.collision_layer = 0
        $Timer.start(2)
        $PreBreak.stop()
        $Break.play()
        $BreakParticles.emitting = true
    else:
        $Unbreak.play()
        $UnbreakParticles.emitting = true
        await $Unbreak.finished
        $Sprites.show()
        $Sprites.scale = Vector2.ZERO
        self.collision_layer = 1
        get_tree().create_tween().tween_property($Sprites, "scale", Vector2(1, 1), 0.2)
        $Cooldown.start(0.25)

func _process(_delta):
    if $Cooldown.is_stopped():
        for body in $Area2D.get_overlapping_bodies():
            if body is Player:
                $Timer.start(0.5)
                $PreBreak.play()
                shake = true
                $Cooldown.start(4)
    if shake:
        $Sprites.position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * (1 - 2 * $Timer.time_left) * SHAKE_INTENSITY
