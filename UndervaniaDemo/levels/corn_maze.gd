extends Level

func _ready():
    Globals.set_flag("tutoriel_prog", 6)
    if Globals.get_flag("secret_prog", 0) < 1:
        Globals.set_flag("secret_prog", 1)
    if Globals.get_flag("corn_maze_done"):
        $Lever.active = true
        for node in $Spikes.get_children():
            node.active = false

func _process(_delta):
    if $Lever.active and not Globals.get_flag("corn_maze_done"):
        for node in $Spikes.get_children():
            node.active = false
        Globals.set_flag("corn_maze_done", true)
