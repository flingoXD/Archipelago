extends Area2D
class_name InteractDoor

@export var destination: String
@export var entry_point: Vector2i
@export var interact_required: bool

enum LOOK{DOWN, LEFT, RIGHT, LEFT_UP, RIGHT_UP}
@export var left_facing: LOOK

var dest_scene

func _ready():
    await get_tree().create_timer(0.5).timeout
    self.collision_mask = 2
    if destination:
        dest_scene = load("res://levels/" + destination + ".tscn")

func _process(_delta):
    if not self.visible:
        return
    for body in self.get_overlapping_bodies():
        if body and body is Player and (body.look == "up" or not interact_required):
            self.hide()
            Globals.grant_room(destination)
            Globals.game_manager.level_transition(dest_scene, Vector2(entry_point) + Vector2(0, -12.5), left_facing)
            await get_tree().create_timer(1).timeout
            self.show()
