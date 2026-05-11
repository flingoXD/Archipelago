extends Node2D
class_name Gauntlet

@export var gauntlet_id: String
@export var music: AudioStream
@export var end_music: AudioStream
@export var music_delay: float
@export var detection: Area2D
@export var collision: StaticBody2D
@export var camera_limit: CameraLimitArea

var waves = []
var cur_wave = 0
var running = false
var player

func _ready():
    for node in self.get_children():
        if node is GauntletWave:
            waves.append(node)
            node.connect("defeated", _on_gauntlet_wave_defeated(node))
    if detection:
        detection.collision_mask = 0 if Globals.get_flag(gauntlet_id) else 2
    if collision:
        collision.collision_layer = 0
    if camera_limit:
        camera_limit.hide()

func _process(_delta):
    if not running and detection:
        for body in detection.get_overlapping_bodies():
            if body is Player:
                start_gauntlet()

func start_gauntlet():
    running = true
    if detection:
        detection.collision_mask = 0
    if collision:
        collision.collision_layer = 1
    if camera_limit:
        camera_limit.show()
    if len(waves) > 0:
        waves[0].start_wave()
        if music_delay:
            Globals.game_manager.play_stream()
            await get_tree().create_timer(music_delay).timeout
        Globals.game_manager.play_stream(music)
    else:
        end_gauntlet()

func end_gauntlet():
    running = false
    if gauntlet_id:
        Globals.set_flag(gauntlet_id, true)
    await get_tree().create_timer(1).timeout
    Globals.game_manager.play_stream(end_music)
    if collision:
        collision.collision_layer = 0
    if camera_limit:
        camera_limit.hide()

func _on_gauntlet_wave_defeated(_node):
    return func():
        cur_wave += 1
        if cur_wave >= len(waves):
            end_gauntlet()
        else:
            await get_tree().create_timer(1).timeout
            waves[cur_wave].start_wave()
