extends Level

var player

func _ready():
    if Globals.get_flag("puzzle_box1"):
        for node in $Puzzle.find_children("*", "LightBox"):
            node.active = true
            node.mutable = false
        $Puzzle / Spikes.active = false
    if Globals.get_flag("rock_candy_collect"):
        $RockCandy / Sign.show()
    player = Globals.game_manager.find_child("Player")

func _process(_delta):
    if $Puzzle / LightBox.active and $Puzzle / LightBox2.active and $Puzzle / LightBox3.active\
and $Puzzle / LightBox4.active and $Puzzle / LightBox5.active and $Puzzle / Spikes.active:
        $Puzzle / Spikes.active = false
        for node in $Puzzle.find_children("*", "LightBox"):
            node.mutable = false
        Globals.set_flag("puzzle_box1", true)
    if not $RockCandy / Sign.visible and not $RockCandy / ItemCollect.visible and player.look != "up":
        $RockCandy / Sign.show()
