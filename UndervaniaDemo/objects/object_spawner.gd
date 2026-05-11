extends Node2D
class_name ObjectSpawner

@export var object_scene: PackedScene
@export var count: int
@export var valid_height = 1
@export var offset: Vector2 = Vector2(10, 10)
@export var tilemap: TileMapLayer

var valid_spawns = []

func _ready():
    count = floor(count * randf_range(0.8, 1.2))
    find_valid_spawns()
    if len(valid_spawns) == 0:
        return
    for i in range(count):
        spawn_object()

func find_valid_spawns():
    valid_spawns = []
    for cell in tilemap.get_used_cells():
        if is_solid(cell) and tilemap.get_used_rect().has_point(cell + Vector2i.UP):
            var valid = true
            for i in range(1, valid_height + 1):
                valid = valid and not is_solid(cell + Vector2i.UP * i)
            if valid:
                valid_spawns.append(cell + Vector2i.UP)

func is_solid(tile_pos):
    var data = tilemap.get_cell_tile_data(tile_pos)
    return data

func spawn_object():
    var pos = valid_spawns.pick_random()
    var new = object_scene.instantiate()
    new.position = tilemap.map_to_local(pos) + Vector2(randf_range( - offset.x, offset.x), offset.y)
    add_child(new)
