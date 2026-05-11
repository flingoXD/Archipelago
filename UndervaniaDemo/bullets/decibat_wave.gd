extends DamageHitbox

func _ready():
    super._ready()
    self.scale = Vector2.ZERO
    get_tree().create_tween().tween_property(self, "scale", Vector2(3, 3), 1.2)
    var tween = get_tree().create_tween()
    tween.tween_interval(1)
    tween.tween_callback( func(): $CollisionPolygon2D.set_deferred("disabled", true))
    tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
    await tween.finished
    self.queue_free()
