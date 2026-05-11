extends Node2D
class_name StartMenu

@export var stream_group: AudioStreamGroup

var game_manager_scene = preload("res://game_manager.tscn")
var submenu_scene = preload("res://start_submenu.tscn")

@onready var level = $NPCs
var old_window_mode

func _init():
    Globals.load_flags()
    Globals.load_settings()

func _ready():

    if not Globals.get_persistent_flag("player_name"):
        var submenu: StartSubmenu = submenu_scene.instantiate()
        submenu.screen = StartSubmenu.SCREEN.CONTROLS
        add_sibling.call_deferred(submenu)
        queue_free()
        return
    var stream = AudioStreamSelection.new()
    stream.stream_group = stream_group
    stream.stream_mask = 2 ** 0 + 2 ** 2
    $Player.look = "down"
    $Player.show()
    if Globals.get_flag("flowey1_done"):
        stream.stream_mask |= 2 ** 3
        $NPCs / Flowey.show()
    if Globals.get_enemy_flag("napstablook") != null:
        stream.stream_mask |= 2 ** 4
        $NPCs / Napstablook.show()
    var decibat = Globals.get_enemy_flag("decibat")
    if decibat != null:
        stream.stream_mask |= 2 ** 4
        if not decibat:
            $NPCs / Decibat.show()
    var toriel = Globals.get_enemy_flag("toriel")
    if toriel != null:
        stream.stream_mask |= 2 ** 1
        if not toriel:
            $NPCs / Flowey.hide()
            $NPCs / Chairiel.show()
    if Globals.get_enemy_flag("strytax") == false:
        stream.stream_mask |= 2 ** 5
        $NPCs / Strytax.show()
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        old_window_mode = DisplayServer.WINDOW_MODE_WINDOWED
    else:
        old_window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
    $MusicPlayer.play(stream)
    $Player.pause()
    await get_tree().create_timer(0.5).timeout
    $Player.unpause()

func _process(_delta):
    if Input.is_action_just_pressed("fullscreen"):
        var temp = DisplayServer.window_get_mode()
        DisplayServer.window_set_mode(old_window_mode)
        old_window_mode = temp

func _on_continue_option_selected():
    $ContinueOption.queue_free()
    $ResetOption.queue_free()
    $SettingsOption.queue_free()
    $Player.pause()
    var tween = get_tree().create_tween()
    tween.tween_property($Menu / ScreenFade, "color", Color.BLACK, 1)
    $MusicPlayer.fade_out()
    await tween.finished
    var game_manager: GameManager = game_manager_scene.instantiate()
    game_manager.start_level = ""
    add_sibling(game_manager)
    queue_free()

func _on_reset_option_selected():
    var submenu: StartSubmenu = submenu_scene.instantiate()
    submenu.screen = StartSubmenu.SCREEN.RESET
    add_sibling(submenu)
    queue_free()

func item_use():
    pass

func _on_settings_option_selected():
    var submenu: StartSubmenu = submenu_scene.instantiate()
    submenu.screen = StartSubmenu.SCREEN.SETTINGS
    add_sibling(submenu)
    queue_free()

func inventory_open():
    pass
