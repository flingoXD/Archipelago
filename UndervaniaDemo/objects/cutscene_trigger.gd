extends Area2D
class_name CutsceneTrigger

@export var pause_player: bool


signal start_cutscene(player)

func _ready():
    await get_tree().create_timer(0.1).timeout
    self.collision_mask = 2
    if not self.is_connected("body_entered", _on_body_entered):
        self.connect("body_entered", _on_body_entered)

func _on_body_entered(body):
    if body is Player and self.visible:
        if pause_player:
            body.pause()
        start_cutscene.emit(body)
        hide()
