extends Area2D

var active = false:
    set(val):
        active = val
        if active:
            $Sprite2D.texture = lever_down
        else:
            $Sprite2D.texture = lever_up

var lever_down = preload("res://sprites/lever_down.png")
var lever_up = preload("res://sprites/lever_up.png")

func _process(_delta):
    if not monitoring:
        return
    for area in self.get_overlapping_areas():
        if area.visible and area.get_parent() is Player and not active:
            active = true
            $AudioStreamPlayer.play()
