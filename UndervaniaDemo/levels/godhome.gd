extends Level

var napstablook = load("res://levels/godhome_napstablook.tscn")
var decibat = load("res://levels/godhome_decibat.tscn")
var toriel = load("res://levels/godhome_toriel.tscn")
var micro = load("res://levels/godhome_micro.tscn")
var strytax = load("res://levels/godhome_strytax.tscn")

var player

func _ready():
    player = Globals.game_manager.find_child("Player")
    player.hp = min(player.hp, player.max_hp)
    if Globals.game_manager.godmode:
        return
    if Globals.get_enemy_flag("napstablook") == null:
        $NapstablookOption.queue_free()
    if Globals.get_enemy_flag("decibat") == null:
        $DecibatOption.queue_free()
    if Globals.get_enemy_flag("toriel") == null:
        $TorielOption.queue_free()
    if Globals.get_enemy_flag("micro_froggit") == null:
        $MicroFroggitOption.queue_free()
    if Globals.get_enemy_flag("strytax") == null:
        $StrytaxOption.queue_free()

func _on_napstablook_option_selected():
    $NapstablookOption.queue_free()
    Globals.game_manager.level_transition(napstablook, Vector2(50, 220) + Vector2(0, -12.5), 0)
    player.hp = min(player.hp, player.max_hp)

func _on_decibat_option_selected():
    $DecibatOption.queue_free()
    Globals.game_manager.level_transition(decibat, Vector2(860, 100) + Vector2(0, -12.5), 0)
    player.hp = min(player.hp, player.max_hp)

func _on_toriel_option_selected():
    $TorielOption.queue_free()
    Globals.game_manager.level_transition(toriel, Vector2(50, 220) + Vector2(0, -12.5), 0)
    player.hp = min(player.hp, player.max_hp)

func _on_micro_froggit_option_selected():
    $MicroFroggitOption.queue_free()
    Globals.game_manager.level_transition(micro, Vector2(560, 200) + Vector2(0, -12.5), 0)
    player.hp = min(player.hp, player.max_hp)

func _on_strytax_option_selected():
    $StrytaxOption.queue_free()
    Globals.game_manager.level_transition(strytax, Vector2(240, 220) + Vector2(0, -12.5), 0)
    player.hp = min(player.hp, player.max_hp)
