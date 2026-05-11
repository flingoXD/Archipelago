extends Timer

var parent
var on_floor = true

func _ready():
    parent = get_parent()

func play():
    $AudioStreamPlayer.pitch_scale = randf_range(0.8, 1)
    $AudioStreamPlayer.play()

func _process(_delta):
    var new = parent.is_on_floor()
    if new and not on_floor:
        play()
        self.start()
    on_floor = new

func _on_timeout():
    if on_floor and parent.velocity.x != 0:
        play()
