extends Level

var toriel_talk = preload("res://sounds/toriel_talk.wav")

var hd_remaster = Globals.get_persistent_flag("silly_shader") == "hd_remaster"

func _ready():
    if Globals.get_flag("tutoriel_prog"):
        $CutsceneTrigger.hide()
        $Toriel.hide()
    if Globals.get_flag("door_puzzle_intro3"):
        $StaticBody2D.hide()
        $StaticBody2D / CollisionShape2D.set_deferred("disabled", true)
    if hd_remaster:
        $Toriel.play("hd_remaster")
        $Toriel.scale = Vector2(0.5, 0.5)
        $Toriel / Textbox.position *= 2
        $Toriel / Textbox.scale *= 2
    if Globals.get_flag("strytax_spare_amulet"):
        Globals.set_flag("strytax_start_room", true)

func _on_cutscene_trigger_start_cutscene(_player):
    $Toriel / Textbox.set_talk_sound(toriel_talk)
    await $Toriel / Textbox.show_text("This way.", 2)
    $Toriel.flip_h = false
    if not hd_remaster:
        $Toriel.play("walk")
    var tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(660, -43), 0.5)
    await tween.finished
    Globals.set_flag("tutoriel_prog", 1)
    $Toriel.hide()
