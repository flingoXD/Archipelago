extends Area2D
class_name DamageHitbox

signal collided(body)

@export var atk: int
@export var remove_after_damage = false
@export var collide_with_ground = false:
    set(val):
        collide_with_ground = val
        collision_mask = 3 if val else 2
@export var remove_on_ground = false
@export var physical = true

@onready var player = Globals.game_manager.find_child("Player")

func _ready():
    if "atk" in get_parent():
        atk += get_parent().atk
    collision_layer = 2
    collision_mask = 3 if collide_with_ground else 2

func _process(_delta):
    if not self.visible:
        return
    var delete = false
    var ground_delete = false
    if player.can_parry(self):
        delete = true
    for body in self.get_overlapping_bodies():
        collided.emit(body)
        if body is Player:
            if body.can_parry(self, true):
                body.parry()
            else:
                body.damage(atk, body.global_position.x < self.global_position.x)
            delete = true
        elif body is not CharacterBody2D:
            ground_delete = true
    if delete and remove_after_damage or ground_delete and remove_on_ground:
        self.queue_free()
