extends Area2D

var active = true:
    set(val):
        active = val
        if active:
            $Sprite2D.texture = spikes_up
        else:
            $Sprite2D.texture = spikes_down

var spikes_up = preload("res://sprites/spikes_up.png")
var spikes_down = preload("res://sprites/spikes_down.png")

func _on_body_entered(body):
    if not active:
        return
    if body is Player:
        body.damage(4)
        body.get_parent().hazard_respawn()
    elif body is Enemy and body.inv <= 0:
        body.call_deferred("do_flee", true)
