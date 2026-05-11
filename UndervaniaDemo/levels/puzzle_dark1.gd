extends Level

func _ready():
    if Globals.get_flag("puzzle_dark1"):
        for node in [$Puzzle / Lever, $Puzzle / Lever2, $Puzzle / Lever3]:
            node.active = true
        $Puzzle / Spikes.active = false
        $Puzzle / Spikes2.active = false
    else:
        var player = Globals.game_manager.find_child("Player")
        if player.position.x < 100:
            player.hazard_respawn = $Puzzle / HazardRespawn.respawn_position

func _process(_delta):
    if $Puzzle / Lever2.active and not $Puzzle / Lever.active or $Puzzle / Lever3.active and not $Puzzle / Lever2.active:
        $AudioStreamPlayer.play()
        for node in [$Puzzle / Lever, $Puzzle / Lever2, $Puzzle / Lever3]:
            node.active = false
            node.monitoring = false
        await get_tree().create_timer(1).timeout
        for node in [$Puzzle / Lever, $Puzzle / Lever2, $Puzzle / Lever3]:
            node.monitoring = true
    if $Puzzle / Lever.active and $Puzzle / Lever2.active and $Puzzle / Lever3.active and $Puzzle / Spikes.active:
        $Puzzle / Spikes.active = false
        $Puzzle / Spikes2.active = false
        Globals.set_flag("puzzle_dark1", true)
