extends Level

var player

func _ready():
    player = Globals.game_manager.find_child("Player")

func _process(_delta):
    player.light_override = remap(player.position.x, 0, 1800, 0.5, 1)
