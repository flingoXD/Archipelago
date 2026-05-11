extends Item

var stick

func on_use(player):
    if (player.weapon):
        if not stick:
            stick = load("res://items/stick.tscn")
        var new = stick.instantiate()
        new.position = player.position
        Globals.game_manager.level.add_child(new)
        if player.flip_h:
            new.linear_velocity.x *= -1
            new.angular_velocity *= -1
        return true
    else: player.wield(self)
