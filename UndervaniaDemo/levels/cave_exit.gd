extends Level

func _ready():
    if Globals.get_enemy_flag("decibat") != false:
        $DecibatTorch / Sprite2D.hide()
