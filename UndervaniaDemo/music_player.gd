extends Node
class_name MusicPlayer

var churchbell_sfx = preload("res://music/churchbell.wav")
var toomuch = preload("res://music/toomuch.tres")

const MUSIC_VOLUME = -3
const FADE_VOLUME = -30

var cur_stream_group: AudioStreamGroup
var cur_stream_mask = 0
var cur_wind

func _ready():
    cur_wind = WindNoise.new()
    add_sibling.call_deferred(cur_wind)

func _play(stream, pos = null, vol = 0):
    var node = AudioStreamPlayer.new()
    node.volume_db = FADE_VOLUME if pos else MUSIC_VOLUME + vol
    node.bus = "Music"
    self.add_child(node)
    node.stream = stream
    node.play(pos if pos else 0)
    if pos:
        create_tween().tween_property(node, "volume_db", MUSIC_VOLUME + vol, 1).set_ease(Tween.EASE_OUT)

func play(stream, fade = true):
    stream = check_genocide(stream)
    if stream is AudioStreamSelection:
        if stream.stream_group == cur_stream_group:
            var new_mask = stream.stream_mask & ~ cur_stream_mask
            var old_mask = cur_stream_mask & ~ stream.stream_mask
            var old_streams = stream.get_streams(old_mask)
            var cur_pos = self.get_child(0).get_playback_position() + AudioServer.get_time_since_last_mix()
            for node in self.get_children():
                if node.stream in old_streams:
                    fade_out_single(node)
            for s in stream.get_streams(new_mask):
                _play(s, cur_pos, cur_stream_group.volume)
        else:
            fade_out(fade)
            for s in stream.get_streams():
                _play(s, null, stream.stream_group.volume)
            cur_stream_group = stream.stream_group
        cur_stream_mask = stream.stream_mask
    else:
        fade_out(fade)
        cur_stream_group = null
        if stream is AudioStream:
            _play(stream)

func fade_out_single(node):
    var tween = create_tween()
    tween.tween_property(node, "volume_db", FADE_VOLUME, 1).set_ease(Tween.EASE_IN)
    tween.tween_callback(node.queue_free)

func fade_out(fade = true):
    var children = self.get_children()
    if len(children) == 0:
        return
    if not fade:
        for node in children:
            node.queue_free()
        return
    var tween = create_tween().set_parallel()
    for node in children:
        tween.tween_property(node, "volume_db", FADE_VOLUME, 1).set_ease(Tween.EASE_IN)
    tween.set_parallel(false)
    for node in children:
        tween.tween_callback(node.queue_free)

func set_wind(wind_level):
    cur_wind.target_volume = remap(wind_level, 0, 1, cur_wind.SILENCE, cur_wind.NORMAL)

func start_genocide():
    play(toomuch)
    _play(churchbell_sfx)

var genocide_swaps = {
    "ruins": toomuch, 
    "dark ruins": toomuch, 
    "pink and gold": toomuch, 
    "start menu": toomuch, 
    "seclusion": toomuch
}

func check_genocide(stream):
    if not stream:
        return
    var stream_name = stream.stream_group.resource_name if stream is AudioStreamSelection else stream.resource_name
    return genocide_swaps[stream_name] if Globals.get_flag("genocide") and stream_name in genocide_swaps else stream
