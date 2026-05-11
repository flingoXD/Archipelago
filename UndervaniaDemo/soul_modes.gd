extends Resource
class_name SoulMode

var player: Player

func start():
    player.soul_color = self.soul_color if "soul_color" in self else null

func end():
    player.soul_color = null

func process(_delta):
    pass

func physics_process(_delta):
    pass

class Red extends SoulMode:
    pass

class Blue extends SoulMode:
    var soul_color = Color.BLUE

    func start():
        super.start()
        player.moves_disabled = true

    func end():
        super.end()
        player.moves_disabled = false
