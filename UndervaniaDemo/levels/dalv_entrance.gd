extends Level

func _ready():
    if Globals.get_flag("dalv_entrance_lever"):
        $Lever.active = true
        $Door.queue_free()
    if Globals.get_flag("dalv_entrance_platform"):
        $Lever2.active = true
        $Platform.position = Vector2.ZERO

func _process(_delta):
    if $Lever.active and not Globals.get_flag("dalv_entrance_lever"):
        Globals.set_flag("dalv_entrance_lever", true)
        $Door.queue_free()
    if $Lever2.active and not Globals.get_flag("dalv_entrance_platform"):
        get_tree().create_tween().tween_property($Platform, "position", Vector2.ZERO, 1)
        Globals.set_flag("dalv_entrance_platform", true)
