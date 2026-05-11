extends Level

var stronger_monsters = preload("res://music/stronger monsters.wav")
var swish = preload("res://music/swish.wav")
var broken_platform = preload("res://objects/broken_platform.tscn")

var granting = false

func _ready():
    if Globals.get_flag("home_tower_done"):
        $Platform.queue_free()
        $CameraLimitArea.hide()
        spawn_platform()
        return
    Globals.game_manager.play_stream()
    await get_tree().create_timer(1.5).timeout
    Globals.game_manager.play_stream(stronger_monsters)

func _process(_delta):
    if granting:
        granting = false
        await get_parent().grant_ability("threat")
        Globals.game_manager.ap_check_location("Act - Threat")
        Globals.set_flag("home_tower_done", true)
        $CameraLimitArea.hide()
        Globals.save_game(self)
        spawn_platform()

func arena_finish():
    get_parent().play_stream(swish)
    await get_tree().create_timer(4).timeout
    granting = true

func spawn_platform():
    var platform = broken_platform.instantiate()
    platform.find_child("Sprites").hide()
    platform.collision_layer = 0
    add_child(platform)
    platform.position = Vector2(80, 170)
    platform._on_timer_timeout()
