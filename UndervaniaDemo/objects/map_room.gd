extends TileMapLayer
class_name MapRoom

@export var room: String
@export var rect: Rect2i
@export var origin: Vector2

@export_group("Flags")
@export var require_flag: String
@export var require_flag_val: Variant
@export var exclude_flag: String
@export var exclude_flag_val: Variant
