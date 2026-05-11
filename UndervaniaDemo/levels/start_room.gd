extends Level

var hd_remaster = Globals.get_persistent_flag("silly_shader") == "hd_remaster"

func _ready():
    if Globals.get_flag("secret_prog", 0) < 2:
        $BrokenPlatform.queue_free()
        $BrokenPlatform2.queue_free()
    if hd_remaster:
        $Toriel.play("hd_remaster")
        $Toriel.scale = Vector2(0.5, 0.5)
        $Toriel / Textbox.position *= 2
        $Toriel / Textbox.scale *= 2
    if not Globals.get_flag("strytax_start_room") or Globals.get_enemy_flag("toriel") != false:
        $Strytax.hide()

func _on_cutscene_trigger_start_cutscene(player):
    Globals.set_flag("hidden_hud", true)
    # player.weapon = load("res://items/stick.tres")
    # player.armour = load("res://items/bandage.tres")


func _on_cutscene_trigger2_start_cutscene(_player):
    Globals.set_flag("secret_start_room", true)
