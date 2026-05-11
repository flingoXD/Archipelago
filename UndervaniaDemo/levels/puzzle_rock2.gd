extends Level

var done = false

func _ready():
    if Globals.get_flag("puzzle_rock2"):
        done = true
        $GoofyRock.position.x = $GoofyRock.lock_x
        $GoofyRock.locked = true
        $GoofyRock2.position.x = $GoofyRock2.lock_x
        $GoofyRock2.locked = true
        $GoofyRockNPC.position.x = 330
        $GoofyRockNPC.locked = true
        $GoofyRockNPC.line = 6
        $GoofyRockNPC.walked_into = true
        $GoofyRockNPC.talkable = true
        $CutsceneTrigger.hide()
        $InteractDoor2.show()

func _process(_delta):
    var locked = $GoofyRock.locked and $GoofyRock2.locked and $GoofyRockNPC.locked
    for node in [$Spikes, $Spikes2, $Spikes3, $Spikes4]:
        node.active = not locked
    if locked and $GoofyRockNPC.line == 6 and not done:
        Globals.set_flag("puzzle_rock2", true)
        done = true
        $InteractDoor2.show()
    $CutsceneTrigger.visible = locked and $GoofyRockNPC.line == 4

func _on_cutscene_trigger_start_cutscene(_player):
    $GoofyRockNPC.line = 5
    $GoofyRockNPC.locked = false
    get_tree().create_tween().tween_property($GoofyRockNPC, "position", Vector2(310, 175), 0.5)
