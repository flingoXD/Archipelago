extends Level

var stronger_monsters = preload("res://music/stronger_monsters.tres")

var buildup
var squeaking = false

func _ready():
    if Globals.get_flag("home_tower_done"):
        $CutsceneTrigger.hide()
        $CutsceneTrigger2.hide()
        $CutsceneTrigger3.hide()
        $Lever.active = true
        $Lever2.active = true
        $Lever3.active = true

func _process(_delta):
    if $Lever.active:
        $Spikes2.active = false
        $Spikes3.active = false
    if $Lever2.active:
        $Spikes4.active = false
    if $Lever3.active:
        $Spikes5.active = false
    var player = Globals.game_manager.find_child("Player")
    if player in $Area2D.get_overlapping_bodies() and player.look == "up":
        if not squeaking:
            squeaking = true
            $AudioStreamPlayer3.play()
    else:
        squeaking = false

func _on_cutscene_trigger_start_cutscene(_player):
    get_parent().play_stream()
    $Door.show()
    $Door.collision_layer = 1
    $Door2.show()
    $Door2.collision_layer = 1
    $AudioStreamPlayer.play()
    $CameraLimitArea / CollisionShape2D.shape.size.x = 160

    $AudioStreamPlayer2.play()
    await get_tree().create_timer(3).timeout
    buildup = AudioStreamSelection.new()
    buildup.stream_group = stronger_monsters
    buildup.stream_mask = 1
    get_parent().play_stream(buildup)

func _on_cutscene_trigger2_start_cutscene(_player):
    buildup.stream_mask = 3
    get_parent().play_stream(buildup)

func _on_cutscene_trigger3_start_cutscene(_player):
    buildup.stream_mask = 15
    get_parent().play_stream(buildup)
