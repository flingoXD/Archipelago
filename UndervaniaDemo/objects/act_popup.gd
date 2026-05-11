extends AnimatedSprite2D

func _ready():
    _process(0)
    await get_tree().create_timer(1).timeout
    self.queue_free()

func _process(_delta):
    flip_h = get_parent().flip_h
    self.position = Vector2(-12 if flip_h else 12, -20)
