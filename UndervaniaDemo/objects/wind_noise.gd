extends AudioStreamPlayer
class_name WindNoise

var wind_sfx = preload("res://sounds/wind.wav")

const SPEED = 0.6
const SILENCE = 0
const NORMAL = 1

var target_volume = SILENCE

func _ready():
    self.stream = wind_sfx
    volume_linear = SILENCE

func _process(delta):
    var dist = target_volume - volume_linear
    if dist != 0:
        var change = SPEED * delta * sign(dist)
        if abs(change) > abs(dist):
            volume_linear = target_volume
        else:
            volume_linear += change
    if volume_linear <= SILENCE:
        stop()
    elif not playing:
        play()
