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

func _process(_delta):
    active = true
    for body in get_overlapping_bodies():
        if body is Player:
            active = false
