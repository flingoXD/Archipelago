extends Level

var first = false
var second = false
var third = false

func _ready():
    for node in find_children("ColorSwitch*"):
        node.connect("pressed", _on_color_switch_pressed(node.get_parent()))

func _on_color_switch_pressed(segment):
    return func(correct, fatal):
        if fatal:
            $AudioStreamPlayer.play()
            get_parent().level_transition(null, Vector2(160, -340))
        elif not correct:
            return
        elif segment == $PerspectiveRoomSegment2:
            $Spikes.active = false
            $Spikes2.active = false
            first = true
        elif segment == $PerspectiveRoomSegment3:
            $Spikes3.active = false
            $Spikes4.active = false
            second = true
        elif segment == $PerspectiveRoomSegment4:
            third = true
        if third:
            $Door.queue_free()
            Globals.set_flag("perspective_room", true)
            for node in find_children("ColorSwitch*"):
                node.monitoring = false
