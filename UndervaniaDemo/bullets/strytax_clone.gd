extends DamageHitbox

var dest: Vector2

func _ready():
    super._ready()
    if not dest:
        queue_free()
        return
    self.position = dest - Vector2.from_angle(self.rotation) * 200
    if self.position.x > dest.x:
        self.scale.y = -1
    var tween = get_tree().create_tween()
    tween.tween_property(self, "position", dest * 2 - self.position, 0.2)
    await tween.finished
    queue_free()
