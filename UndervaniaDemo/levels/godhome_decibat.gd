extends Level

var godhome = load("res://levels/godhome.tscn")

func _ready():
    $Decibat.start_fight.call_deferred()

func exit():
    await get_tree().create_timer(2).timeout
    Globals.game_manager.level_transition(godhome, Vector2(30, 107.5), 0)
