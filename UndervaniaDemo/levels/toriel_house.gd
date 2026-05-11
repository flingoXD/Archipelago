extends Level

var toriel_talk = preload("res://sounds/toriel_talk.wav")

const text = [
    "Do you smell that?", 
    "Surprise!", 
    "It is a butterscotch-cinnamon pie.", 
    "I thought we might celebrate your arrival.", 
    "I want you to have a nice time living here.", 
    "So I will hold off on snail pie for tonight.", 
    "Here, I have another surprise for you."
]

var hd_remaster = Globals.get_persistent_flag("silly_shader") == "hd_remaster"

func get_stream():
    if not Globals.get_enemy_flag("toriel"):
        return stream

func _ready():
    var prog = Globals.get_flag("toriel_home_prog", 0)
    if prog >= 2:
        $Toriel.hide()
        $CutsceneTrigger.hide()
    if prog == 3:
        $Chairiel.show()
    if Globals.get_flag("genocide"):
        $Sign8.text[0] = "[color=red]Where are the knives.[/color]"
    if hd_remaster:
        $Toriel.play("hd_remaster")
        $Toriel.scale = Vector2(0.5, 0.5)
        $Toriel / Textbox.position *= 2
        $Toriel / Textbox.scale *= 2
        $Chairiel.play("hd_remaster")
        $Chairiel.scale = Vector2(0.5, 0.5)
        $Chairiel / Textbox.position *= 2
        $Chairiel / Textbox.scale *= 2
    if not Globals.get_flag("toriel_bed"):
        $PiePart.hide()
        $Sign10.text[0] = "What a nice smell... too hot to eat, though."
    if Globals.get_enemy_flag("toriel"):
        $Sign9.text[0] = "No one will use this any more..."

func _on_cutscene_trigger_start_cutscene(player):
    $Toriel / Textbox.set_talk_sound(toriel_talk)
    await $Toriel / Textbox.show_text(text)
    if not hd_remaster:
        $Toriel.play("walk")
    $Toriel.flip_h = false
    var tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(260, 177), 0.5)
    await tween.finished
    if not hd_remaster:
        $Toriel.play("default")
    await get_tree().create_timer(0.5).timeout
    if not hd_remaster:
        $Toriel.play("up")
    await get_tree().create_timer(0.5).timeout
    $Toriel.hide()
    Globals.set_flag("toriel_home_prog", 2)
    player.unpause()

func toriel_leave():
    if hd_remaster:
        await get_tree().create_timer(1).timeout
    else:
        $Chairiel.play("getup")
        await $Chairiel.animation_finished
    $Chairiel.hide()
    $Toriel.position.x = 380
    $Toriel.flip_h = true
    $Toriel.show()
    if not hd_remaster:
        $Toriel.play("walk")
    var tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(140, 177), 1.5)
    await tween.finished
    if not hd_remaster:
        $Toriel.play("default")
    await get_tree().create_timer(0.5).timeout
    if not hd_remaster:
        $Toriel.play("up")
    await get_tree().create_timer(0.5).timeout
    $Toriel.hide()
    Globals.set_flag("toriel_home_prog", 4)
