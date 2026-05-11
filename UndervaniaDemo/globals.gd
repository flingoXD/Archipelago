extends Node
class_name Globals

static var game_manager: GameManager
static var _flags = {"kills": 0}
static var _enemy_flags = {}
static var _persistent_flags = {}
static var _abilities = []
static var _rooms = []
static var flag_path = "user://flags.dat"
static var enemy_flag_path = "user://enemy_flags.dat"
static var persistent_flag_path = "user://persistent_flags.dat"
static var map_path = "user://map.dat"
static var player_path = "user://player.dat"
static var items = {}
static var kill_total = 107

const _PW = "this is just so players can't simply read their save data and edit it lmao"
const talk_acts = ["talk", "cheer", "threat"]
const acts = ["talk", "cheer", "check", "threat"]
const moves = ["glide", "lantern"]

static var input_keys = {
    "talk": "talk", 
    "cheer": "act1", 
    "glide": "jump", 
    "check": "check", 
    "threat": "act2"
}

const geno_excluded = [
    "napstablook", 
    "toriel", 
    "strytax", 
    "strytax_arena_whimsun", 
    "strytax_arena_whimsdux", 
    "quiry_teaser_boree", 
    "micro_froggit", 
    "otavio_the_cockroach_mage"
]

const save_point_positions = {
    "old_tomb3": Vector2i(190,-700),
    "ruins_entrance": Vector2i(590,120),
    "froggit_room1": Vector2i(230,380),
    "dark_lobby": Vector2i(570,100),
    "home_entrance": Vector2i(690,200),
    "home_tower": Vector2i(190,220),
    "imperfect_ideal": Vector2i(150,200),
    "dalv_entrance": Vector2i(690,280)
}

const silly_shaders = {
    "antique": preload("res://silly_shaders/antique.gdshader"), 
    "spoooooky": preload("res://silly_shaders/spoooooky.gdshader"), 
    "8_bit": preload("res://silly_shaders/retro.gdshader"), 
    "invert": preload("res://silly_shaders/invert.gdshader"), 
    "extra_vibrant": preload("res://silly_shaders/vibrant.gdshader"), 
    "neon_outlines": preload("res://silly_shaders/outlines.gdshader"), 
    "myopia": preload("res://silly_shaders/gaussian.gdshader"), 
    "hd_remaster": null, 
    "australia": preload("res://silly_shaders/australia.gdshader")
}

const ap_location_name_to_id = {
    "Candy Corn": 1,
    "Corn Dog": 2,
    "Strytax's Sword": 3,
    "Faded Ribbon": 4,
    "Golden Pear": 5,
    "Lemonade": 6,
    "Monster Candy": 7,
    "Buy Raffle Ticket": 8,
    "Raffle Ticket Rewards": 9,
    "Pie": 10,
    "Rock Candy": 11,
    "Shadow Amulet": 12,
    "Spider Store 1": 13,
    "Spider Store 2": 14,
    "Toy Knife": 15,
    "Act - Talk": 16,
    "Act - Cheer": 17,
    "Act - Threat": 18,
    "Act - Check": 19,
    "Wings": 20,
    "Corn Maze Chest": 21,
    "Home Large Room Chest": 22,
    "Tutorial Chest": 23,
    "Cheer Room Chest": 24,
    "Old Tomb Chest": 25,
    "Lantern": 26,
}

const item_name_to_ap_thing = {
    "candy_corn": "Candy Corn",
    "corn_dog": "Corn Dog",
    "dusty_broadsword": "Strytax's Sword",
    "faded_ribbon": "Faded Ribbon",
    "golden_pear": "Golden Pear",
    "lemonade": "Lemonade",
    "monster_candy": "Monster Candy",
    "not_punchcard": "Buy Raffle Ticket",
    "pie": "Pie",
    "rock_candy": "Rock Candy",
    "shadow_amulet": "Shadow Amulet",
    "spider_cider": "Spider Store 2",
    "spider_donut": "Spider Store 1",
    "toy_knife": "Toy Knife",
    "bandage": "Bandage",
    "stick": "Stick",
    "chest_corn_maze": "Corn Maze Chest",
    "chest_home": "Home Large Room Chest",
    "chest_puzzle_intro3": "Tutorial Chest",
    "chest_snowdin_overlook": "Cheer Room Chest",
    "chest_start_room": "Old Tomb Chest",
    "Act - Talk": "Act - Talk",
    "Act - Cheer": "Act - Cheer",
    "Act - Check": "Act - Check",
    "Act - Threat": "Act - Threat",
    "Glide": "Glide",
    "10 Gold": "10 Gold",
    "lantern": "Lantern"
}

static func get_key_name(action):
    return OS.get_keycode_string(InputMap.action_get_events(action)[0].physical_keycode)

static func set_flag(flag, val):
    print("Set flag " + flag + " to " + str(val))
    _flags[flag] = val
    game_manager.find_child("Map").move_to_center()

static func get_flag(flag, default = null):
    if flag in _flags:
        return _flags[flag]
    return default

static func set_enemy_flag(flag, val):
    print("Set enemy flag " + flag + " to " + str(val))
    _enemy_flags[flag] = val
    if val:
        if flag not in geno_excluded:
            _flags["kills"] += 1
        check_genocide()
    else:
        abort_genocide()

static func get_enemy_flag(flag):
    if flag in _enemy_flags:
        return _enemy_flags[flag]
    else:
        return null

static func set_persistent_flag(flag, val):
    print("Set persistent flag " + flag + " to " + str(val))
    _persistent_flags[flag] = val
    _save_file(persistent_flag_path, _persistent_flags)

static func get_persistent_flag(flag, default = null):
    if flag in _persistent_flags:
        return _persistent_flags[flag]
    return default

static func grant_ability(ability):
    _abilities.append(ability)

static func has_ability(ability):
    return ability in _abilities

static func has_any_act_ability():
    for act in acts:
        if has_ability(act):
            return true
    return false

static func grant_room(room):
    if not has_room(room):
        _rooms.append(room)

    game_manager.find_child("Map").move_to_center(room)

static func has_room(room):
    return room in _rooms

static func save_game(room: Level):
    _save_file(flag_path, _flags)
    _save_file(enemy_flag_path, _enemy_flags)
    _save_file(persistent_flag_path, _persistent_flags)
    _save_file(map_path, _rooms)
    var player: Player = game_manager.find_child("Player")

    var inventory = []
    for item in player.inventory:
        if item:
            inventory.append(item.item_id)
    _save_file(player_path, {
        "lvl": player.lvl, 
        "gold": player.gold, 
        "xp": player.xp, 
        "room": trim_level(room.scene_file_path), 
        "abilities": _abilities, 


        "weapon": player.weapon.item_id if player.weapon else null, 
        "armour": player.armour.item_id if player.armour else null, 
        "inventory": inventory
    })

static func _save_file(filepath, data):
    var file = FileAccess.open_encrypted_with_pass(filepath, FileAccess.WRITE, _PW)
    file.store_string(JSON.stringify(data))

static func load_flags():
    if not FileAccess.file_exists(player_path) or not FileAccess.file_exists(persistent_flag_path):
        return
    _flags = _load_file(flag_path)
    _enemy_flags = _load_file(enemy_flag_path)
    _persistent_flags = _load_file(persistent_flag_path)
    _abilities = _load_file(player_path)["abilities"]

static func load_game():
    if not FileAccess.file_exists(player_path) or not FileAccess.file_exists(persistent_flag_path):
        return
    _flags = _load_file(flag_path)
    _enemy_flags = _load_file(enemy_flag_path)
    _persistent_flags = _load_file(persistent_flag_path)
    _rooms = _load_file(map_path)
    var player_data = _load_file(player_path)
    var player: Player = game_manager.find_child("Player")
    player.player_name = _persistent_flags["player_name"] if "player_name" in _persistent_flags else "Chara"
    player.lvl = 0
    player.lvl = player_data["lvl"]
    player.gold = player_data["gold"]
    player.xp = player_data["xp"]
    _abilities = player_data["abilities"]
    game_manager.start_level = trim_level(player_data["room"])
    game_manager.find_child("Map").move_to_center(game_manager.start_level)
    player.wield(get_item_from_id(player_data["weapon"]))
    player.wear(get_item_from_id(player_data["armour"]))
    for item_id in player_data["inventory"]:
        player.inventory.append(get_item_from_id(item_id))

static func _load_file(filepath):
    var file = FileAccess.open_encrypted_with_pass(filepath, FileAccess.READ, _PW)
    return JSON.parse_string(file.get_as_text())

static func trim_level(level: String):
    return level.trim_suffix(".tscn").split("/")[-1]

static func delete_save(true_reset = false):
    for path in [flag_path, enemy_flag_path, player_path, map_path]:
        _delete_file(path)
    _flags = {"kills": 0}
    _enemy_flags = {}
    _abilities = []
    _rooms = []
    if true_reset:
        _delete_file(persistent_flag_path)

static func _delete_file(filepath):
    if FileAccess.file_exists(filepath):
        DirAccess.remove_absolute(filepath)

static func get_item_from_id(item_id):
    if len(items) == 0:
        for res in DirAccess.get_files_at("res://items"):
            res = res.trim_suffix(".remap")
            if res.ends_with(".tres"):
                var item = load("res://items/" + res)
                if "item_id" in item:
                    items[item.item_id] = item
    return items[item_id].duplicate() if item_id else null

static func check_genocide():
    if not kill_total:
        kill_total = 1 + 3 + 4 + 3
        var all_rooms = load("res://that_scene_where_i_put_every_level_next_to_each_other.tscn").instantiate()
        for room in all_rooms.get_children():
            if room is Level:
                print(room.name)
                for enemy in room.find_children("*", "Enemy"):
                    if not enemy.enemy_id:
                        print("no id")
                    elif enemy.enemy_id in geno_excluded:
                        print("id excluded")
                    else:
                        kill_total += 1
                        print(enemy.enemy_id)
        print("Finished calculating kill total: ", kill_total)
    if get_flag("kills") >= kill_total and get_flag("genocide") == null:
        set_flag("genocide", true)
        game_manager.start_genocide()

static func abort_genocide():
    var old_genocide = get_flag("genocide")
    if old_genocide != false:
        set_flag("genocide", false)
        if old_genocide:
            game_manager.abort_genocide()

static func load_settings():
    var master_bus = AudioServer.get_bus_index("Master")
    var music_bus = AudioServer.get_bus_index("Music")
    AudioServer.set_bus_volume_linear(master_bus, get_persistent_flag("volume_master", 1))
    AudioServer.set_bus_volume_linear(music_bus, get_persistent_flag("volume_music", 1))
    InputMap.load_from_project_settings()
    for action in InputMap.get_actions():
        var bind = get_persistent_flag("keybind_" + action)
        if bind:
            var event = InputEventKey.new()
            event.physical_keycode = OS.find_keycode_from_string(bind)
            InputMap.action_erase_events(action)
            InputMap.action_add_event(action, event)

    
