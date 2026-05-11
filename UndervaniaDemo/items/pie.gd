extends Item

func do_eat(player):
    player.hp = max(player.hp, player.max_hp)
