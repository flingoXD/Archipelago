extends Node2D

var time = 1

func _ready():
    self.modulate.a = 0
    $ColorRect.position.y = 10
    $ColorRect2.position.y = -10
    var tween = get_tree().create_tween().set_parallel()
    tween.tween_property(self, "modulate", Color.WHITE, time)
    tween.tween_property($ColorRect, "position", Vector2($ColorRect.position.x, 0), time)
    tween.tween_property($ColorRect2, "position", Vector2($ColorRect2.position.x, 0), time)
    await tween.finished
    queue_free()
