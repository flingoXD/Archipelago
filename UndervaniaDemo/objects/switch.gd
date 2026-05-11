extends Area2D

var active = false
var switch_down = preload("res://sprites/switch_down.png")

func _on_body_entered(body):
    if body is Player and not active:
        active = true
        $AudioStreamPlayer.play()
        $Sprite2D.texture = switch_down
