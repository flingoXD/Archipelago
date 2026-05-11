extends Level

func _ready():
    if Globals.get_flag("door_froggit_room2"):
        $Lever.active = true
        $Door.queue_free()

func _process(_delta):
    if $Lever.active and not Globals.get_flag("door_froggit_room2"):
        $Door.queue_free()
        Globals.set_flag("door_froggit_room2", true)
