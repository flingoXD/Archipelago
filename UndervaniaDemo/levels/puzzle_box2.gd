extends Level

func get_stream():
    if Globals.has_ability("glide"):
        stream.stream_mask |= 2 ** 9 + 2 ** 8
    return stream

func _ready():
    if Globals.get_flag("puzzle_box2") or Globals.has_ability("glide"):
        for node in $Puzzle.find_children("*", "LightBox"):
            node.active = true
            node.mutable = false
        $FakeWall.queue_free()

        $CameraLimitArea2.hide()
    if Globals.has_ability("glide"):
        $CutsceneTrigger.hide()
        $Bridge.queue_free()
    if Globals.get_enemy_flag("home_tower_crispy_scroll") == null:
        $CrispyScroll.queue_free()
    if Globals.get_flag("dalv_entrance_lever"):
        $Door.queue_free()

func _process(_delta):
    if Globals.get_flag("puzzle_box2") or Globals.has_ability("glide"):
        return
    for node in $Puzzle.find_children("*", "LightBox"):
        if not node.active:
            return
    $FakeWall.wall_break()

    $CameraLimitArea2.hide()
    for node in $Puzzle.find_children("*", "LightBox"):
        node.mutable = false
    Globals.set_flag("puzzle_box2", true)

func _on_cutscene_trigger_start_cutscene(player):
    await get_parent().grant_ability("glide")
    Globals.game_manager.ap_check_location("Wings")
    stream.stream_mask |= 2 ** 9 + 2 ** 8
    get_parent().play_stream(stream)
    $Bridge.queue_free()
    Globals.save_game(self)
    player.unpause()
