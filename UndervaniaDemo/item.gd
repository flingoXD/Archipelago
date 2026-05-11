extends Resource
class_name Item

var item_sfx = preload("res://sounds/item.wav")

@export var item_id = ""
@export var display_name = ""
@export var nickname = ""
@export var serious_name = ""
@export var edible = false
@export var eat_hp = 0
@export var wieldable = false
@export var wield_atk = 0
@export var wearable = false
@export var wear_def = 0
@export var display_stats = ""
@export_multiline var description = ""

func on_pickup(player):
    player.play_sound(item_sfx)

func on_drop(_player):
    return true

func on_use(player):
    player.play_sound(item_sfx)
    if edible:
        do_eat(player)
    elif wieldable:
        player.wield(self)
    elif wearable:
        player.wear(self)
    else:
        return false
    return true

func do_eat(player):
    player.heal(eat_hp)

func on_wield(player):
    player.atk_mod += wield_atk

func on_unwield(player):
    player.atk_mod -= wield_atk

func on_wear(player):
    player.def_mod += wear_def

func on_unwear(player):
    player.def_mod -= wear_def

func on_process(_delta):
    pass

func save_data():
    pass

func load_data(_data = null):
    pass

func get_nickname(serious = false):
    if serious and serious_name:
        return serious_name
    return nickname if nickname else display_name
