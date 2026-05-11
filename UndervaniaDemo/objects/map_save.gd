extends Button
@export var level: String = ""

func _on_pressed() -> void:
    await Globals.game_manager.level_transition(load("res://levels/" + level + ".tscn"), Vector2(Globals.save_point_positions[level]) + Vector2(0, -12.5))
    var map = find_parent("Map")
    map.move_to_center(level)
