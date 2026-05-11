extends TileMapLayer
class_name FakeWall

@export var wall_id: String
@export var break_area: Area2D

var wall_break_sfx = preload("res://sounds/wall_break.wav")

func _ready():
    if wall_id and Globals.get_flag(wall_id):
        self.queue_free()

func _process(_delta):
    if not break_area or not self.visible:
        return
    for area in break_area.get_overlapping_areas():
        if area.visible and area.get_parent() is Player:
            if area.get_parent().weapon: wall_break()

func wall_break():
    var audio = AudioStreamPlayer.new()
    get_parent().add_child(audio)
    audio.stream = wall_break_sfx
    audio.play()
    Globals.set_flag(wall_id, true)
    self.queue_free()
