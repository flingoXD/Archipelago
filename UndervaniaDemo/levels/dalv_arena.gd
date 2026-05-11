extends Level

var fakewall
var light

func _ready():
    fakewall = find_child("FakeWall")
    light = find_child("PointLight2D")
    if fakewall and light:
        light.hide()

func _process(_delta):
    if light and not fakewall:
        light.show()

func _on_cutscene_trigger_start_cutscene(_player):
    Globals.set_flag("dalv_arena_done", true)

func _on_cutscene_trigger2_start_cutscene(_player):
    $AudioStreamPlayer.play()
