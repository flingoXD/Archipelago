extends Label

func show_title(title):
    self.modulate = Color.TRANSPARENT
    self.text = title
    var tween = get_tree().create_tween()
    tween.tween_property(self, "modulate", Color.WHITE, 1)
    tween.tween_interval(2)
    tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
    await tween.finished
