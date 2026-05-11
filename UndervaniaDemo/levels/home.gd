extends Level

@export var drum_roll: AudioStream

var lift_down = false
var lift_moving = false

const lift_up_pos = Vector2(0, -460)
const lift_down_pos = Vector2(0, 120)

func get_stream():
    var player_pos = Globals.game_manager.find_child("Player").position
    if player_pos.y < -200 and player_pos.x < 120 and not Globals.get_flag("home_reveal"):
        return drum_roll
    Globals.set_flag("home_reveal", true)
    $CutsceneTrigger.hide()
    return stream

func _ready():
    var player_pos = Globals.game_manager.find_child("Player").position
    if player_pos.y < -200 and player_pos.x < 120:
        $Platform.position = lift_up_pos
    else:
        $Platform.position = lift_down_pos
        lift_down = true
    $TextureRect.hide()

func _process(_delta):
    if ($Lever.active or $Lever2.active) and not lift_moving:
        lift_moving = true
        lift_down = not lift_down
        var tween = create_tween()
        tween.tween_interval(1)
        tween.tween_property($Platform, "position", lift_down_pos if lift_down else lift_up_pos, 24)
        await tween.finished
        lift_moving = false
        $Lever.active = false
        $Lever2.active = false

func _on_cutscene_trigger_start_cutscene(_player):
    Globals.set_flag("home_reveal", true)
    get_parent().play_stream(stream)
