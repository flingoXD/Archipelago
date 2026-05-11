extends Level

var old_mask = 2 ** 16

func get_stream():
    if Globals.game_manager.find_child("Player").position.x > 300:
        $CutsceneTrigger.hide()
        $CutsceneTrigger2.show()
        switch_stream()
    return stream

func switch_stream():
    var new_mask = old_mask
    old_mask = stream.stream_mask
    stream.stream_mask = new_mask

func _on_cutscene_trigger_start_cutscene(_player):
    $CutsceneTrigger2.show()
    switch_stream()
    get_parent().play_stream(stream)

func _on_cutscene_trigger2_start_cutscene(_player):
    $CutsceneTrigger.show()
    switch_stream()
    get_parent().play_stream(stream)
