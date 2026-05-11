extends Level

func _ready():
    await get_tree().create_timer(1).timeout
    var player = Globals.game_manager.find_child("Player")
    player.damage(100)
