extends Level

func _ready():
    if Globals.get_flag("fakewall_puzzle_pitfall1"):
        $Door.queue_free()
        $Lever.active = true

func _process(_delta):
    if $Lever.active and not Globals.get_flag("fakewall_puzzle_pitfall1"):
        Globals.set_flag("fakewall_puzzle_pitfall1", true)
        $Door.queue_free()

func _on_cutscene_trigger_start_cutscene(_player):
    $AudioStreamPlayer.play()
    $AudioStreamPlayer2.play()
    Globals.set_flag("pitfall1_done", true)
    await get_tree().create_timer(1).timeout
    $CutsceneTrigger.show()
