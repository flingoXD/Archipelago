extends Node2D
class_name GameManager

var level: Level:
    set(val):
        level = val
        $Player / Camera.level = val
        if val:
            play_stream(val.get_stream())
            $Player.light_override = val.light_override
            $CanvasModulate.color.v = 0.1 + 0.1 * val.light_override
            $MusicPlayer.set_wind(val.wind)
@export var start_level: String
var start_level_scene

@export var godmode: bool
@export var inf_health: bool
@export var fixed_camera: bool

var boss_bar_scene = preload("res://objects/boss_bar.tscn")
var death_scene = preload("res://objects/death_screen.tscn")
var gaining = preload("res://music/ability gaining.wav")
var stalker = preload("res://enemies/flowey_stalker.tscn")
var start_menu = load("res://start_menu.tscn")

var map_viewing = false
var old_window_mode
var title
var title_delay = 0
var serious = false
var stalker_time = 0
var dying = false

func play_stream(stream = null, fade = true):
    $MusicPlayer.play(stream, fade)
    if stream is AudioStreamSelection:
        var new_title = stream.stream_group.title
        if title != new_title:
            if new_title:
                title = new_title
                title_delay = stream.stream_group.title_delay
            return
        elif new_title:
            return
    if title_delay > 0:
        title_delay = 0
        title = null

func _ready():
    Globals.game_manager = self
    Archipelago.connected.connect(_ap_on_connect)
    if start_level:
        Globals._persistent_flags = Globals._load_file(Globals.persistent_flag_path)
        Globals.grant_room(start_level)
    else:
        Globals.load_game()
    Globals.load_settings()
    godmode = godmode and OS.is_debug_build()
    if godmode:
        for act in Globals.acts:
            Globals.grant_ability(act)
        for move in Globals.moves:
            Globals.grant_ability(move)
        Globals._abilities.remove_at(Globals._abilities.find("lantern"))
        $Player.inventory = []
        $Player.weapon = null
        $Player.armour = null
        $Player.wield(load("res://items/toy_knife.tres"))
        $Player.wear(load("res://items/faded_ribbon.tres"))



        for i in range(7):
            $Player.inventory.append(load("res://items/spider_cider.tres").duplicate())





        $Player.inventory.append(load("res://items/shadow_amulet.tres").duplicate())
        $Player.gold = 100000


        if fixed_camera:
            $Player / Camera.position_smoothing_enabled = false
    else:
        inf_health = false
        fixed_camera = false
    if not start_level_scene:
        if not start_level:
            start_level = "start_room"
        start_level_scene = load("res://levels/" + start_level + ".tscn")
    switch_level(start_level_scene)
    $Player.position = Vector2(level.default_point) + Vector2(0, -12.5)
    $Player.hazard_respawn = $Player.position
    $Player / Camera.reset_smoothing()
    $GUI / ScreenFade.fade_in()
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        old_window_mode = DisplayServer.WINDOW_MODE_WINDOWED
    else:
        old_window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN

func switch_level(new_scene: PackedScene):
    if level:
        level.queue_free()
    if not new_scene:
        level = null
        return
    level = new_scene.instantiate()
    self.add_child(level)
    self.move_child(level, 0)
    for node in $GUI.get_children():
        if node is BossBar:
            node.queue_free()
    serious = false

func level_transition(new_scene, entry_point, look = null):
    $Player.pause()
    $Player.wind = 0
    if look in [InteractDoor.LOOK.LEFT_UP, InteractDoor.LOOK.RIGHT_UP]:
        $Player.door_move.y = - Player.JUMP_SPEED * 0.5
    $Player.door_move.x = $Player.velocity.x
    await $GUI / ScreenFade.fade_out()
    $Player.position = entry_point
    $Player.velocity = Vector2.ZERO
    $Player.door_move = Vector2.ZERO
    if not look or look == InteractDoor.LOOK.DOWN:
        $Player.look = "down"
        $Player.flip_h = false
    else:
        $Player.look = "default"
        $Player.flip_h = look in [InteractDoor.LOOK.LEFT, InteractDoor.LOOK.LEFT_UP]
    if new_scene:
        switch_level(new_scene)
        $Player.fighting = []
        $Player.hazard_respawn = entry_point
    await $GUI / ScreenFade.fade_in()
    $Player.unpause()

func hazard_respawn():
    $Player.velocity = Vector2.ZERO
    level_transition(null, Vector2($Player.hazard_respawn) + Vector2(0, -12.5))

func grant_ability(ability, flag = null):
    pause()
    play_stream()
    $MusicPlayer.set_wind(0)
    await $GUI / ScreenFade.fade_out()
    await $GUI / AbilityCutscene.run(ability, flag)
    await $GUI / ScreenFade.fade_in()
    unpause()
    if (flag): Globals.grant_ability(ability)
    $MusicPlayer.set_wind(level.wind)

func _process(delta):
    if Input.is_action_just_pressed("fullscreen"):
        var temp = DisplayServer.window_get_mode()
        DisplayServer.window_set_mode(old_window_mode)
        old_window_mode = temp
    if godmode and Input.is_action_just_pressed("freecam") and ($Player / Camera.freecam or not $Player.paused):
        if $Player / Camera.freecam:
            $Player.unpause()
            $Player.show()
            $Player / Camera.freecam = false
            $CanvasModulate.show()
        else:
            $Player.pause()
            $Player.hide()
            $Player.look = "down"
            $Player / Camera.freecam = true
            $CanvasModulate.hide()
    if Input.is_action_just_pressed("map") and not $Player.paused:
        map_viewing = true
        $Player.pause()
        $GUI / SVC / SV / Map.move_to_center()
    if Input.is_action_pressed("map") and map_viewing and $Player.paused < 2:
        $GUI / SVC.modulate.a = min($GUI / SVC.modulate.a + delta * 4, 0.8)
        $GUI / SVC / SV / Map.update()
        $GUI / SVC / SV / Map.handle_inputs(delta)
    else:
        $GUI / SVC.modulate.a = max($GUI / SVC.modulate.a - delta * 4, 0)
        if map_viewing:
            map_viewing = false
            $Player.unpause()
    if title and title_delay > 0:
        title_delay -= delta / Engine.time_scale
        if title_delay <= 0:
            title_delay = 0
            $GUI / Title.show_title(title)
    if $Player.hp <= 0 and not dying:
        dying = true
        $Player.pause()
        await get_tree().create_timer(0.1).timeout
        add_sibling(death_scene.instantiate())
        queue_free()
    if $Player.weapon:
        $Player.weapon.on_process(delta)
    if $Player.armour:
        $Player.armour.on_process(delta)
    for item in $Player.inventory:
        if item:
            item.on_process(delta)
    stalker_time += delta
    if stalker_time > 300:
        stalker_time = 0
        if level and level.flowey_stalk:
            var spawner = ObjectSpawner.new()
            spawner.object_scene = stalker
            spawner.count = 1
            spawner.tilemap = level.find_child("Walls")
            level.add_child(spawner)
    if $Player.position.y > 10000:
        level_transition(null, $Player.hazard_respawn)
    if $GUI / HurtVignette.modulate.a > 0:
        $GUI / HurtVignette.modulate.a -= delta * 2

func create_boss_bar(boss_name, color):
    var boss_bar = boss_bar_scene.instantiate()
    boss_bar.initialize(boss_name, color)
    $GUI / HUD.add_sibling(boss_bar)
    return boss_bar

func show_credits():
    $MusicPlayer.play(gaining)
    $GUI / ScreenFade.color = Color.TRANSPARENT
    await $GUI / ScreenFade.fade_out(5)
    await get_tree().create_timer(1).timeout
    $GUI / ScreenFade.color = Color.BLACK
    for frame in [$GUI / GameTitle, $GUI / Credits, $GUI / Credits2, $GUI / Credits3, $GUI / Credits4]:
        frame.show()
        $GUI / GameTitle / AudioStreamPlayer.play()
        await get_tree().create_timer(5).timeout
        frame.hide()

func pause():
    $Player.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
    level.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
    $Player / Camera.paused = true

func unpause():
    $Player.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
    level.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
    await get_tree().create_timer(0.1).timeout
    $Player / Camera.paused = false

func item_use():
    pause()
    var item: Item = await $GUI / ItemUse.pick_item()
    unpause()
    $Player.pause()
    @warning_ignore("redundant_await")
    if item and await item.on_use($Player):
        $Player.inventory.pop_at($Player.inventory.find(item))
    await get_tree().create_timer(0.01).timeout
    $Player.unpause()
    return item

func inventory_open():
    $Player.pause()
    pause()
    $GUI / Inventory.show_inventory()
    await $GUI / Inventory.inventory_exit
    unpause()
    await get_tree().create_timer(0.5).timeout
    $Player.unpause()

func start_genocide():
    $MusicPlayer.start_genocide()

func abort_genocide():
    play_stream(level.get_stream())

func hurt_vignette():
    $GUI / HurtVignette.modulate.a = 1

func _on_hud_quit():
    $Player.pause()
    play_stream()
    await $GUI / ScreenFade.fade_out()
    var menu = start_menu.instantiate()
    add_sibling(menu)
    queue_free()

func camera_shake(val):
    if Globals.get_persistent_flag("camera_shake", true):
        $Player / Camera.shake = max($Player / Camera.shake, val)

func _obtained_item(item: NetworkItem):
    var iname: String = item.get_name()
    print(iname)
    var iname1 = Globals.item_name_to_ap_thing.find_key(iname)
    if (iname1 == null):
        var item1
        match iname:
            "Spider Cider":
                item1 = load("res://items/spider_cider.tres")
            "Spider Donut":
                item1 = load("res://items/spider_donut.tres")
        $Player.inventory.append(item1)
    elif ("Act - " in iname1):
        match iname1:
            "Act - Cheer":
                await grant_ability("cheer",1)
            "Act - Talk":
                await grant_ability("talk",1)
            "Act - Threat":
                await grant_ability("threat",1)
            "Act - Check":
                await grant_ability("check",1)
    elif iname1=="10 Gold": $Player.earn_gold(10)
    elif iname1=="lantern": Globals.grant_ability("lantern")
    else:
        match iname1:
            "lemonade":
                Globals.set_flag("lemonade_collect", true)
        var item1 = load("res://items/"+iname1+".tres")
        $Player.inventory.append(item1)

func _ap_on_connect(conn: ConnectionInfo, _json: Dictionary):
    Archipelago.conn.obtained_item.connect(_obtained_item)

func ap_check_location(item):
    var ind = Globals.ap_location_name_to_id[Globals.item_name_to_ap_thing[item]]
    Archipelago.collect_location(ind)
    return true
