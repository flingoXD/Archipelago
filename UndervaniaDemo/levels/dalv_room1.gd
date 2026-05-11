extends Level

var fallen_warrior = preload("res://music/fallen warrior.wav")
var lever_down = preload("res://sprites/lever_down.png")

const text = [
    [
        "How long has it been? Weeks, years, centuries?", 
        "Look at the Fliers of the air.\nThey have wings, they could do it.", 
        "But they cannot conceive of it. Nobody can conceive of it, except I.", 
        "Was it foolhardy to do this? To leave my home and seek asylum in these ruins?", 
        "They are old, maybe, but I have known older.", 
        "It was, I think, a necessary sacrifice."
    ], 
    [
        "But what is this I hear? Like the tread of a Migosp or a Loox, perhaps...", 
        "Yet they do not venture to these depths. What are you?"
    ], 
    [
        "...", 
        "A human... after all this time?", 
        "Could this be the opportunity I have long awaited?"
    ]
]

var velocity = 0

func _ready():
    var prog = Globals.get_flag("secret_prog", 0)
    if prog >= 1:
        $CutsceneTrigger.hide()
    if prog >= 2 or Globals.get_flag("dalv_room1_platform"):
        $Strytax.hide()
        $Platform.position = Vector2.ZERO
        $FakeLever.texture = lever_down

func _on_cutscene_trigger_start_cutscene(player):
    $Strytax / Textbox.position.x = -45
    get_parent().play_stream(fallen_warrior)
    await $Strytax / Textbox.show_text(text[0])
    await get_tree().create_timer(1).timeout
    await $Strytax / Textbox.show_text(text[1])
    $Strytax.flip_h = true
    await get_tree().create_timer(0.5).timeout
    await $Strytax / Textbox.show_text(text[2])
    await get_tree().create_timer(0.5).timeout
    Globals.set_flag("secret_prog", 1)
    player.unpause()
    get_parent().play_stream(self.stream)
    $Strytax / Textbox.position.x = 0

func _process(delta):
    if Globals.get_flag("secret_prog", 0) >= 1 and $Strytax.animation == "cloaked":
        $Strytax.flip_h = $Strytax.position.x > Globals.game_manager.find_child("Player").position.x
    if velocity:
        $Strytax.position.y += velocity * delta

func lower_platform():
    $Strytax.play("cloaked_up")
    var old_flip_h = $Strytax.flip_h
    var old_pos = $Strytax.position
    $Strytax.flip_h = false
    await get_tree().create_timer(0.5).timeout
    velocity = -350
    create_tween().tween_property(self, "velocity", 350, 0.7)
    await get_tree().create_timer(0.35).timeout
    $FakeLever.texture = lever_down
    $FakeLever / AudioStreamPlayer.play()
    Globals.set_flag("dalv_room1_platform", true)
    create_tween().tween_property($Platform, "position", Vector2.ZERO, 1.5)
    await get_tree().create_timer(0.35).timeout
    velocity = 0
    $Strytax.position = old_pos
    await get_tree().create_timer(0.5).timeout
    $Strytax.play("cloaked")
    $Strytax.flip_h = old_flip_h
    await get_tree().create_timer(0.5).timeout
