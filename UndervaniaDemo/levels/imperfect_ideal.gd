extends Level

func _ready():
    var player: Player = Globals.game_manager.find_child("Player")
    var removals = []
    for i in range(len(player.inventory)):
        if player.inventory[i].item_id == "memory":
            removals.push_front(i)
    for i in removals:
        player.inventory.pop_at(i)
