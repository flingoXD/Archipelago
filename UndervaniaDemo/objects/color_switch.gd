extends Area2D

@export_enum("red", "green", "blue") var color: String
@export var correct: bool
@export var fatal: bool

signal pressed(correct, fatal)

var cooldown = 0

func _ready():
    $AnimatedSprite2D.play(color)

func _process(delta):
    if not monitoring:
        return
    cooldown -= delta
    if cooldown > 0:
        return
    for area in self.get_overlapping_areas():
        if area.visible and area.get_parent() is Player:
            $AudioStreamPlayer.play()
            pressed.emit(correct, fatal)
            cooldown = 1
