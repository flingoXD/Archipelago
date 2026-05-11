extends DamageHitbox

var target
var lunging = true

func _process(delta):
    if self.modulate.a < 1:
        return
    super._process(delta)
    if not lunging:
        return
    if not target:
        self.queue_free()
        return
    if target.state == target.STATE.LUNGE:
        self.rotation = self.position.direction_to(target.position).angle()
        self.scale.x = self.position.distance_to(target.position) * 0.1
    else:
        lunging = false
        var tween = get_tree().create_tween()
        tween.tween_interval(2)
        tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
        await tween.finished
        self.queue_free()
