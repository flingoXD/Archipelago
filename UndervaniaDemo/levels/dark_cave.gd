extends Level

func _ready():
    if Globals.get_flag("micro_prog", 0) >= 5:
        $FakeWall2.queue_free()
