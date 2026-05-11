extends Level

var player: Player
var sprite: AnimatedSprite2D

@export_group("Reflection")
@export var offset: Vector2
@export var min_pos: Vector2
@export var max_pos: Vector2

var toriel_talk = preload("res://sounds/toriel_talk.wav")

const text = [
    [
        "This is it...", 
        "A room of your own.\nI hope you like it!", 
    ], 
    "Is something burning?\nUm, make yourself at home!"
]

var hd_remaster = Globals.get_persistent_flag("silly_shader") == "hd_remaster"

func get_stream():
    if not Globals.get_enemy_flag("toriel"):
        return stream

func _ready():
    player = Globals.game_manager.find_child("Player")
    sprite = player.find_child("AnimatedSprite2D")
    if Globals.get_flag("toriel_home_prog", 0) >= 3:
        $Toriel.hide()
        $CutsceneTrigger.hide()
    else:
        $InteractDoor2.hide()
    if Globals.get_flag("genocide"):
        $Sign4.text[0] = "It's me, " + player.player_name + "."
    if hd_remaster:
        $Toriel.play("hd_remaster")
        $Toriel.scale = Vector2(0.5, 0.5)
        $Toriel / Textbox.position *= 2
        $Toriel / Textbox.scale *= 2
    if Globals.get_flag("water_sausage"):
        $Sign.hide()
        $Sign3.show()

func _process(_delta):
    match sprite.animation:
        "up":
            $Reflection.play("down")
        "down":
            $Reflection.play("up")
        _:
            $Reflection.play(sprite.animation)
    $Reflection.flip_h = player.flip_h
    $Reflection.position = (player.position + offset).clamp(min_pos, max_pos)

func _on_cutscene_trigger_start_cutscene(p):
    player = p
    $Toriel / Textbox.set_talk_sound(toriel_talk)
    await $Toriel / Textbox.show_text(text[0])
    await get_tree().create_timer(0.5).timeout
    sprite.hide()
    player.look = "up"
    if not hd_remaster:
        $Toriel.play("ruffle")
    $Toriel.flip_h = false
    await get_tree().create_timer(3).timeout
    if not hd_remaster:
        $Toriel.play("up")
    sprite.show()
    await get_tree().create_timer(0.5).timeout
    if not hd_remaster:
        $Toriel.play("default")
    $Toriel.flip_h = true
    await $Toriel / Textbox.show_text(text[1])
    if not hd_remaster:
        $Toriel.play("walk")
    var tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(60, 177), 0.5)
    await tween.finished
    if not hd_remaster:
        $Toriel.play("default")
    await get_tree().create_timer(0.5).timeout
    if not hd_remaster:
        $Toriel.play("up")
    await get_tree().create_timer(0.5).timeout
    $Toriel.hide()
    Globals.set_flag("toriel_home_prog", 3)
    player.unpause()
    while player.look == "up":
        await get_tree().create_timer(0.1).timeout
    $InteractDoor2.show()
