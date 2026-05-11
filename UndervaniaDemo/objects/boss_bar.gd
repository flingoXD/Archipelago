extends ProgressBar
class_name BossBar

func initialize(boss_name, color):
    self.modulate = Color(color, 0)
    $Label.text = boss_name
    create_tween().tween_property(self, "modulate", color, 1)

func _process(_delta):
    if Input.is_action_just_pressed("hidden_hud"):
        self.visible = not self.visible

func discard():
    var tween = get_tree().create_tween()
    tween.tween_property(self, "modulate", Color(self.modulate, 0), 1)
    await tween.finished
    self.queue_free()
