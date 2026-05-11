extends Node2D
class_name Level

@export var default_point: Vector2i
@export var light_override: float

@export_group("Limits")
@export var limit_top: int
@export var limit_bottom: int
@export var limit_left: int
@export var limit_right: int

@export_group("Music")
@export var stream: AudioStream
@export var wind: float

@export_group("Misc")
@export var flowey_stalk = true

func get_stream():
    return stream

func _enter_tree():
    if get_parent() == get_tree().root:
        var game_manager = load("res://game_manager.tscn").instantiate()
        Globals.game_manager = game_manager
        game_manager.start_level = Globals.trim_level(self.scene_file_path)
        add_sibling.call_deferred(game_manager)
        self.queue_free()
