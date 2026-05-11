extends AnimatedSprite2D
class_name NPC

var selected = false:
    set(val):
        selected = val
        if selected:
            self.material = select_shader
        else:
            self.material = null

var select_shader = preload("res://objects/select.tres")

var talkable = true

func talk(_act):
    pass

func check():
    pass
