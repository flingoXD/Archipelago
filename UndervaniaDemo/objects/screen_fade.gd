extends ColorRect

func fade_out(time = 0.5):
    var tween = get_tree().create_tween()
    tween.tween_property(self, "color", Color(self.color, 1), time)
    await tween.finished

func fade_in():
    var tween = get_tree().create_tween()
    tween.tween_property(self, "color", Color(self.color, 0), 0.5)
    await tween.finished
