extends Area2D

var gold_scene = preload("res://objects/gold.tscn")

@export var chest_id: String
@export var gold = 0

func _ready():
    if chest_id and Globals.get_flag(chest_id):
        self.queue_free()

func _process(_delta):
    if not monitoring or not visible:
        return
    for area in self.get_overlapping_areas():
        if area.visible and area.get_parent() is Player:
            $AudioStreamPlayer.play()
            Globals.set_flag(chest_id, true)
            #for i in gold:
                #var new = gold_scene.instantiate()
                #add_sibling(new)
                #new.position = self.position
                #new.linear_velocity = Vector2(randf_range(-1, 1), randf_range(-2, 0)).normalized() * randi_range(200, 300)
            Globals.game_manager.ap_check_location(chest_id)
            self.hide()
            await $AudioStreamPlayer.finished
            self.queue_free()
