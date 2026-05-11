extends Level

func _ready():
    if Globals.get_flag("fakewall_puzzle_pitfall1"):
        $Door.queue_free()
