extends Level

var toriel_talk = preload("res://sounds/toriel_talk.wav")
var switch_down = preload("res://sprites/switch_down.png")
var lever_down = preload("res://sprites/lever_down.png")

const text = [
    [
        "Welcome to your new home, innocent one.", 
        "Allow me to educate you in the operation of the RUINS."
    ], 
    [
        "The RUINS are full of puzzles.\nAncient fusions between diversions and doorkeys.", 
        "One must solve them to move from room to room.", 
        "Please adjust yourself to the sight of them."
    ]
]

const GRAVITY = 960
var dest_x = 1000
var jump_time = 0
var floor_waiting = false
var hd_remaster = Globals.get_persistent_flag("silly_shader") == "hd_remaster"

signal dest_reached

func _ready():
    var flag = Globals.get_flag("tutoriel_prog")
    if flag and flag >= 2:
        $CutsceneTrigger.hide()
        $Toriel.hide()
        $FakeSwitch1.texture = switch_down
        $FakeSwitch2.texture = switch_down
        $FakeLever.texture = lever_down
        $FakeDoor.hide()
    if hd_remaster:
        $Toriel / AnimatedSprite2D.play("hd_remaster")
        $Toriel / AnimatedSprite2D.scale = Vector2(0.5, 0.5)

func _on_cutscene_trigger_start_cutscene(player):
    $Toriel / Textbox.set_talk_sound(toriel_talk)
    await $Toriel / Textbox.show_text(text[0])
    await get_tree().create_timer(0.5).timeout
    await jump_on_switches()
    $Toriel / Textbox.position.x = -20
    await $Toriel / Textbox.show_text(text[1])
    $Toriel / AnimatedSprite2D.flip_h = false
    if not hd_remaster:
        $Toriel / AnimatedSprite2D.play("walk")
    var tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(330, 197), 0.5)
    await tween.finished
    Globals.set_flag("tutoriel_prog", 2)
    $Toriel.hide()
    player.unpause()

func jump_on_switches():
    $Toriel.velocity.x = 160
    $Toriel.velocity.y = -320
    jump_time = 0.1
    $Toriel / AnimatedSprite2D.flip_h = false
    if not hd_remaster:
        $Toriel / AnimatedSprite2D.play("walk")
    await reach_floor()
    $FakeSwitch1.texture = switch_down
    $AudioStreamPlayer.play()
    $Toriel.velocity.y = -320
    await reach(174)
    await reach_floor()
    $FakeSwitch2.texture = switch_down
    $AudioStreamPlayer.play()
    await reach(260)
    $Toriel.velocity.x = 0
    if not hd_remaster:
        $Toriel / AnimatedSprite2D.play("default")
    await get_tree().create_timer(0.5).timeout
    if not hd_remaster:
        $Toriel / AnimatedSprite2D.play("up")
    await get_tree().create_timer(0.5).timeout
    $FakeLever.texture = lever_down
    $AudioStreamPlayer.play()
    $FakeDoor.hide()
    await get_tree().create_timer(0.5).timeout
    $Toriel / AnimatedSprite2D.flip_h = true
    if not hd_remaster:
        $Toriel / AnimatedSprite2D.play("default")

func reach(x):
    dest_x = x
    await dest_reached

func reach_floor():
    floor_waiting = true
    await dest_reached

func _physics_process(delta):
    if jump_time > 0:
        jump_time -= delta
        $Toriel.velocity.y = -320
    else:
        $Toriel.velocity.y += GRAVITY * delta
    $Toriel.move_and_slide()
    if $Toriel.position.x >= dest_x or $Toriel.is_on_floor() and floor_waiting:
        dest_reached.emit()
        floor_waiting = false
