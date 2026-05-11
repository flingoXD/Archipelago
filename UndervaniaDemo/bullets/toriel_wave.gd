extends Node2D

@onready var battle_rig = get_parent()

var time = 0
var spawn_time = 0
var spawning = true
var do_sound = false

func _ready():
    if do_sound:
        $WaveAudio.volume_linear = 0
        $WaveAudio.pitch_scale = randf_range(1, 1.4)
        get_tree().create_tween().tween_property($WaveAudio, "volume_linear", 1, 0.5)
        $WaveAudio.play()

func _process(delta):
    time += delta
    if time >= 2 and spawning:
        spawning = false
        if do_sound:
            var tween = get_tree().create_tween()
            tween.tween_property($WaveAudio, "volume_linear", 0, 3)
            await tween.finished
        self.queue_free()
    if not spawning:
        return
    spawn_time -= delta
    if spawn_time <= 0:
        spawn_time += 0.05
        battle_rig.spawn_bullet(battle_rig.TYPE.WAVE, self.position, Vector2(90, 0.6), 4)
        battle_rig.spawn_bullet(battle_rig.TYPE.WAVE, self.position, Vector2(-90, 0.6), 4)
