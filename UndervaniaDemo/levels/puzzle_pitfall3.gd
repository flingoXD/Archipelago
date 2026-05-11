extends Level

func _ready():
    if Globals.get_flag("door_puzzle_pitfall3"):
        $Lever.active = true
        $Door.queue_free()
    if not Globals.get_flag("perspective_room"):
        $InteractDoor7.hide()
        $InteractDoor6.show()

func _process(_delta):
    if $Lever.active and not Globals.get_flag("door_puzzle_pitfall3"):
        $Door.queue_free()
        Globals.set_flag("door_puzzle_pitfall3", true)

func _on_cutscene_trigger_start_cutscene(_player):
    $AudioStreamPlayer.play()
    $AudioStreamPlayer2.play()
    Globals.set_flag("pitfall3_done", true)
    await get_tree().create_timer(1).timeout
    $CutsceneTrigger.show()

func _on_cutscene_trigger2_start_cutscene(_player):
    Globals.set_flag("pitfall3_done", true)
