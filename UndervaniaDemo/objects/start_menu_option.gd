extends Area2D

@export var text: String

signal selected

func _ready():
    $Label.text = text

func _process(_delta):
    if not monitoring:
        return
    for body in self.get_overlapping_bodies():
        if body is Player and body.look == "up":
            $AudioStreamPlayer2.play()
            selected.emit()

func _on_body_entered(_body):
    $AudioStreamPlayer.play()
    $Label / TextureRect.show()

func _on_body_exited(_body):
    $Label / TextureRect.hide()
