extends Level

func _ready():
    Globals.set_flag("tutoriel_prog", 6)
    if Globals.get_flag("puzzle_rock1"):
        $GoofyRock.position.x = $GoofyRock.lock_x
        $GoofyRock.locked = true
        $Door / CollisionShape2D.set_deferred("disabled", true)
        $Door.hide()

func _on_goofy_rock_lock():
    $Door / CollisionShape2D.set_deferred("disabled", true)
    $Door.hide()
    Globals.set_flag("puzzle_rock1", true)
