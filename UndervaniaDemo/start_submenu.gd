extends Control
class_name StartSubmenu

@export var menu_stream: AudioStream

var start_menu_scene = load("res://start_menu.tscn")
var wingdings = preload("res://fonts/pixelated-wingdings.otf")
var determination = preload("res://fonts/DeterminationMonoWebRegular-Z5oq.ttf")
var comic_sans = preload("res://fonts/pixel-comic-sans-undertale-sans-font.otf")
var world_revolving = preload("res://music/the world revolving excerpt.wav")
var gaining = preload("res://music/ability gaining.wav")
var game_manager_scene = preload("res://game_manager.tscn")
var once_upon_a_time = preload("res://music/once upon a time.wav")

enum SCREEN{RESET, CONTROLS, NAME, FADE_OUT, SETTINGS, KEYBINDS, TRUE_RESET}
var screen: SCREEN = SCREEN.CONTROLS
var jevil_secret = false
var skipping = 0
var slider_selected:
    set(val):
        if slider_selected:
            slider_selected.modulate.a = 0.8
        if val:
            val.modulate.a = 1
        slider_selected = val
var old_window_mode
var keybind_selected

@onready var slider_settings = {
    $SettingsMenu / VolumeOption / HSlider: "volume_master", 
    $SettingsMenu / MusicOption / HSlider: "volume_music"
}

const special_names = {
    "AAAAAA": "You can do better than that!", 
    "CHARA": "The true name.", 
    "MUGSY": "(Elite ball knowledge.)", 
    "NAPSTA": "............\n(They're powerless to stop you.)", 
    "BLOOKY": "............\n(They're powerless to stop you.)", 
    "TEMMIE": "hOI!", 
    "TEM": "hOI!", 
    "DECIBA": "Hushh hushh...", 
    "DECBAT": "Hushh hushh...", 
    "TOGORE": "Togore-tastic!", 
    "IDEAL": "No you're not... are you?", 
    "IDEALT": "No you're not... are you?", 
    "MELON": "You'll be happy to know I did not\nforget the water sausage lore.", 


    "MERG": "Taking a break from Silksong I see...", 
    "PEENIX": "Please do a pacifist route this time...", 

    "OINK": "Play the actual game first, like I tried\nto get you to.", 
    "MYSTIC": "Hey mom I'm famous!", 
    "SVEN": "Bro you still haven't finished the\nactual game.", 

    "SUB": "Subscribe. Do what it says.", 
    "CIBLES": "Hey mom I'm famous!"
}

const blocked_names = {
    "ASGORE": "You cannot.", 
    "ASRIEL": "...", 
    "FLOWEY": "I already CHOSE that name.", 
    "SANS": "nope.", 
    "TORIEL": "I think you should think of your own\nname, my child.", 
    "DALV": "Please... don't do that.", 
    "FRISK": "This would make your life hell,\nbut it's not implemented yet.", 
    "ROUXLS": "Useth not mine Appellatione, worm!", 
    "KRIS": "...", 
    "STRYTA": "You must seek your own path, human.\nDo not follow in mine.", 
    "STRYTX": "You must seek your own path, human.\nDo not follow in mine.", 
    "STRTAX": "You must seek your own path, human.\nDo not follow in mine.", 
    "CLOVER": "C'mon, pardner. Shouldn't you use\nyour own name?"
}

func _ready():
    for node in self.get_children():
        if node.name.ends_with("Menu"):
            node.hide()
    match screen:
        SCREEN.RESET:
            $ResetMenu.show()
            $ResetMenu / MenuOption.select()
            $ResetMenu / MenuOption / AudioStreamPlayer2.play()
        SCREEN.CONTROLS:
            $ControlsMenu.show()
            $MusicPlayer.play(menu_stream)
        SCREEN.SETTINGS:
            $SettingsMenu.show()
            $SettingsMenu / VolumeOption.select()
            for slider in slider_settings:
                slider.value = Globals.get_persistent_flag(slider_settings[slider], 1)
            update_shader_option()
            for bind: Label in $KeybindsMenu / VBoxContainer.get_children() + $KeybindsMenu / VBoxContainer2.get_children():
                bind.text = bind.text.split(":")[0] + ": [" + get_keybind_setting(bind.name.to_lower()) + "]"
                bind.connect("selected", on_keybind_selected(bind))
            if not Globals.get_enemy_flag("toriel") and ( not Globals.game_manager or not Globals.game_manager.godmode):
                $SettingsMenu / TrueResetOption.hide()
                $SettingsMenu / ShakeOption.neighbor_down = $SettingsMenu / MenuOption
                $SettingsMenu / MenuOption.neighbor_up = $SettingsMenu / ShakeOption
            var shake = Globals.get_persistent_flag("camera_shake", true)
            $SettingsMenu / ShakeOption.text = "Camera Shake: " + ("On" if shake else "Off")
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        old_window_mode = DisplayServer.WINDOW_MODE_WINDOWED
    else:
        old_window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN

func get_keybind_setting(bind):
    var flag = Globals.get_persistent_flag("keybind_" + bind)
    return flag if flag else Globals.get_key_name(bind)

func _process(delta):
    if Input.is_action_just_pressed("fullscreen"):
        var temp = DisplayServer.window_get_mode()
        DisplayServer.window_set_mode(old_window_mode)
        old_window_mode = temp
    if Input.is_anything_pressed():
        if screen == SCREEN.CONTROLS:
            $ControlsMenu / AudioStreamPlayer.play()
            screen = SCREEN.NAME
            $ControlsMenu.hide()
            $NameMenu.show()
            $NameMenu / AudioStreamPlayer.play()
        elif has_node("AbilityCutscene") and $AbilityCutscene.visible or $SkipLabel.visible:
            skipping += delta
            if skipping >= 3:
                skipping = 0
                skip_cutscene()
    else:
        skipping = 0
    if screen == SCREEN.NAME:
        $NameMenu.grab_focus()
        $NameMenu / Label.label_settings.font = determination
        $NameMenu / Label.label_settings.font_size = 16
        var text_upper = $NameMenu.text.to_upper()
        match text_upper:
            "GASTER":
                $NameMenu / Label.label_settings.font = wingdings
                $NameMenu / Label2.label_settings.font = wingdings
                $NameMenu.add_theme_font_override("font", wingdings)
                await get_tree().create_timer(0.05).timeout
                get_tree().quit()
            "TOBY":
                $NameMenu.text = ""
                $NameMenu / Bork.play()
            "PHOENI":
                $NameMenu.text = "Peenix"
            "NESS":
                $NameMenu.text = "sans"
            "SANS":
                $NameMenu / Label.text = "nope."
                $NameMenu / Label.label_settings.font = comic_sans
                $NameMenu / Label.label_settings.font_size = 14
            "JEVIL":
                $NameMenu / Label.text = "UEE HEE HEE! A GAME, GAME!!"
                if not jevil_secret:
                    jevil_secret = true
                    $MusicPlayer.play(world_revolving)
                    await get_tree().create_timer(20.5).timeout
                    if screen == SCREEN.NAME:
                        $MusicPlayer.play(menu_stream)
            _:
                if text_upper in blocked_names:
                    $NameMenu / Label.text = blocked_names[text_upper]
                elif text_upper in special_names:
                    $NameMenu / Label.text = special_names[text_upper]
                elif $NameMenu / Label.text not in ["Name the fallen human.", "A name must be chosen."]:
                    $NameMenu / Label.text = "Name the fallen human."
        $NameMenu.caret_column = len($NameMenu.text)
    elif screen == SCREEN.SETTINGS and slider_selected:
        slider_selected.value += Input.get_axis("left", "right") * 0.01
        if Input.is_action_just_pressed("text_enter") or Input.is_action_just_pressed("text_show"):
            Globals.set_persistent_flag(slider_settings[slider_selected], slider_selected.value)
            var option = slider_selected.get_parent()
            slider_selected = null
            await get_tree().create_timer(0.01).timeout
            option.select()

func _on_menu_option_selected():
    add_sibling(start_menu_scene.instantiate())
    queue_free()

func _on_reset_option_selected():
    Globals.delete_save(screen == SCREEN.TRUE_RESET)
    $ResetMenu.process_mode = Node.PROCESS_MODE_DISABLED
    await fade_out()
    $ResetMenu.hide()
    if screen == SCREEN.TRUE_RESET:
        get_tree().quit()
    else:
        await start_cutscene()
        start_game()

func _on_name_menu_text_submitted(player_name):
    if player_name == "":
        $NameMenu.release_focus()
        $NameMenu.grab_focus.call_deferred()
        $NameMenu / Label.text = "A name must be chosen."
        return
    elif player_name.to_upper() in blocked_names:
        $NameMenu.release_focus()
        $NameMenu.grab_focus.call_deferred()
        return
    $NameMenu.process_mode = Node.PROCESS_MODE_DISABLED
    await fade_out()
    Globals.set_persistent_flag("player_name", player_name)
    $NameMenu.hide()
    await start_cutscene()
    start_game()

func start_game():
    var game_manager: GameManager = game_manager_scene.instantiate()
    game_manager.start_level = "start_room"
    add_sibling(game_manager)
    game_manager.find_child("Player").player_name = Globals.get_persistent_flag("player_name")
    Globals.save_game(game_manager.level)
    queue_free()

func fade_out():
    screen = SCREEN.FADE_OUT
    var tween = get_tree().create_tween()
    tween.tween_property($ColorRect, "color", Color.WHITE, 5)
    $MusicPlayer.play(gaining)
    await tween.finished
    await get_tree().create_timer(1).timeout
    $ColorRect.color = Color.TRANSPARENT

func start_cutscene():
    $MusicPlayer.play(once_upon_a_time)
    $SkipLabel.show()
    await get_tree().create_timer(3).timeout
    $SkipLabel.hide()
    await $AbilityCutscene.intro()
    $Title.show()
    $Title / AudioStreamPlayer.play()
    await get_tree().create_timer(5).timeout

func skip_cutscene():
    $MusicPlayer.play(null)
    var tween = get_tree().create_tween()
    tween.tween_property($AbilityCutscene, "modulate", Color.BLACK, 2)
    await tween.finished
    $AbilityCutscene.queue_free()
    $Title.show()
    $Title / AudioStreamPlayer.play()
    await get_tree().create_timer(5).timeout
    start_game()

func _on_volume_option_selected():
    $SettingsMenu / VolumeOption / TextureRect.hide()
    slider_selected = $SettingsMenu / VolumeOption / HSlider

func _on_music_option_selected():
    $SettingsMenu / MusicOption / TextureRect.hide()
    slider_selected = $SettingsMenu / MusicOption / HSlider

func update_shader_option(shader = null):
    if not shader:
        shader = Globals.get_persistent_flag("silly_shader")
    if shader == "hd_remaster":
        $SettingsMenu / ShaderOption.text = "Silly Shader: HD Remaster"
    else:
        $SettingsMenu / ShaderOption.text = "Silly Shader: " + (shader if shader else "none").capitalize()

func _on_shader_option_selected():
    var shaders = Globals.silly_shaders.keys() + [null]
    var shader = Globals.get_persistent_flag("silly_shader")
    shaders.remove_at(shaders.find(shader))
    shader = shaders.pick_random()
    Globals.set_persistent_flag("silly_shader", shader)
    update_shader_option(shader)

func _on_keybinds_option_selected():
    screen = SCREEN.KEYBINDS
    $SettingsMenu.hide()
    $KeybindsMenu.show()
    $SettingsMenu / KeybindsOption / TextureRect.hide()
    await get_tree().create_timer(0.01).timeout
    $KeybindsMenu / VBoxContainer / Up.select()

func _on_settings_option_selected():
    screen = SCREEN.SETTINGS
    $SettingsMenu.show()
    $KeybindsMenu.hide()
    $KeybindsMenu / SettingsOption / TextureRect.hide()
    await get_tree().create_timer(0.01).timeout
    $SettingsMenu / KeybindsOption.select()

func on_keybind_selected(bind: Label):
    return func():
        bind.find_child("TextureRect").hide()
        bind.text = bind.text.split(":")[0] + ": ..."
        keybind_selected = bind

func _input(event):
    if screen == SCREEN.KEYBINDS and keybind_selected and event is InputEventKey and event.is_pressed():
        var bind = keybind_selected
        keybind_selected = null
        var bind_name = OS.get_keycode_string(event.physical_keycode)
        Globals.set_persistent_flag("keybind_" + bind.name.to_lower(), bind_name)
        bind.text = bind.text.split(":")[0] + ": [" + bind_name + "]"
        await get_tree().create_timer(0.01).timeout
        bind.select()

func _on_reset_bind_option_selected():
    InputMap.load_from_project_settings()
    for bind: Label in $KeybindsMenu / VBoxContainer.get_children() + $KeybindsMenu / VBoxContainer2.get_children():
        var bind_name = bind.name.to_lower()
        Globals.set_persistent_flag("keybind_" + bind_name, null)
        bind.text = bind.text.split(":")[0] + ": [" + Globals.get_key_name(bind_name) + "]"

func _on_true_reset_option_selected():
    screen = SCREEN.TRUE_RESET
    $SettingsMenu.hide()
    $ResetMenu.show()
    $ResetMenu.text = "Are you sure?\nThe game will be completely reset!"
    await get_tree().create_timer(0.01).timeout
    $ResetMenu / MenuOption.select()

func _on_shake_option_selected():
    var shake = not Globals.get_persistent_flag("camera_shake", true)
    Globals.set_persistent_flag("camera_shake", shake)
    $SettingsMenu / ShakeOption.text = "Camera Shake: " + ("On" if shake else "Off")
