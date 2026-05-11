extends Level

func _ready():
    if Globals.get_flag("puzzle_rock1"):
        $Door.queue_free()
    if Globals.get_flag("door_froggit_room2"):
        $Door2.queue_free()

func _on_cutscene_trigger_start_cutscene(_player):
    $AudioStreamPlayer.play()
    $AudioStreamPlayer2.play()
    Globals.set_flag("pitfall2_done", true)
    await get_tree().create_timer(1).timeout
    $CutsceneTrigger.show()

func _on_cutscene_trigger2_start_cutscene(_player):
    Globals.set_flag("pitfall2_top", true)
