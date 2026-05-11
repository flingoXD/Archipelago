extends Level

func get_stream():
    if Globals.has_ability("cheer"):
        stream.stream_mask |= 2 ** 14
    return stream

func _ready():
    if Globals.has_ability("cheer"):
        $CutsceneTrigger.hide()
    if Globals.get_flag("puzzle_rock2"):
        $Spikes3.active = false
        $Spikes4.active = false
        $Spikes5.active = false
    else:
        $InteractDoor.hide()
    if floor(Globals.get_flag("secret_prog", 0)) != 2:
        $Strytax.hide()
        $NPC.hide()

func _on_cutscene_trigger_start_cutscene(player):
    await get_parent().grant_ability("cheer")
    Globals.game_manager.ap_check_location("Act - Cheer")
    stream.stream_mask |= 2 ** 14
    get_parent().play_stream(stream)
    Globals.save_game(self)
    player.unpause()

func _on_cutscene_trigger2_start_cutscene(_player):
    Globals.set_flag("snowdin_overlook_done", true)
