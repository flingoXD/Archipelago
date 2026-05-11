extends Area2D
class_name ItemCollect

@export var item: Item
@export var collect_id = ""

var displaying = false

func _ready():
    self.collision_mask = 2
    if Globals.get_flag(collect_id):
        self.queue_free()

func _process(_delta):
    if not self.visible:
        return
    for body in self.get_overlapping_bodies():
        if body is Player and body.look == "up" and not body.flip_h:
            if Globals.game_manager.ap_check_location(item.item_id):
                self.hide()
                Globals.set_flag(collect_id, true)
            elif not displaying:
                body.pause()
                displaying = true
                await body.find_child("Textbox").show_text("You try to pick it up, but you don't have any room.")
                await get_tree().create_timer(0.5).timeout
                body.unpause()
            return
    displaying = false
