extends AnimatedSprite2D

var memory = preload("res://items/memory.tres")

func _process(_delta):
    for area in $Area2D.get_overlapping_areas():
        if area.visible and area.get_parent() is Player:
            if $Area2D.visible:
                $Area2D.hide()
                $GPUParticles2D.emitting = true
                if not area.get_parent().add_item(memory.duplicate()):
                    $AudioStreamPlayer.play()
            return
    $Area2D.show()
