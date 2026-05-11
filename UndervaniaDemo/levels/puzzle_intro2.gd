extends Level

var toriel_talk = preload("res://sounds/toriel_talk.wav")

var hd_remaster = Globals.get_persistent_flag("silly_shader") == "hd_remaster"

const text = [
    [
        "To make progress here, you will need to trigger several switches.", 
        "To flip a switch, just jump up and hit it.", 
        "First you must flip the bottom one, so that the spikes will retract.", 
        "Then you will be able to reach the top one and open the door."
    ], 
    [
        "No no no! You want to press the other switch.", 
        "That is the wrong switch."
    ], 
    [
        "I do not know what will happen if you press that switch.", 
        "It is safer to press the other switch and continue."
    ], 
    [
        "I remember the last person who pressed that switch, several years ago.", 
        "They did not return.", 
        "Now be a good child and press the other switch instead."
    ]
]

func _ready():
    var flag = Globals.get_flag("tutoriel_prog", 0)
    if flag >= 2.1:
        $CutsceneTrigger.hide()
    if flag >= 2.2:
        $Lever.active = true
        $Spikes.active = false
        $Spikes2.active = false
    if flag >= 3:
        $Lever2.active = true
        $Door / CollisionShape2D.set_deferred("disabled", true)
        $Door.hide()
        $Toriel.hide()
        $CutsceneTrigger2.hide()
        $CutsceneTrigger3.hide()
        $CutsceneTrigger4.hide()
    if Globals.has_room("dark_entrance") or flag >= 3:
        $CutsceneTrigger2.hide()
        $CutsceneTrigger3.hide()
        $CutsceneTrigger4.hide()
        $CutsceneTrigger5.hide()
        var player_pos = Globals.game_manager.find_child("Player").position
        if player_pos.x > 600 and player_pos.y > 150:
            Globals.set_flag("fakewall_puzzle_intro2", true)
            Globals.set_flag("door_puzzle_intro2", true)
    if Globals.get_flag("fakewall_puzzle_intro2"):
        $FakeWall.hide()
        $FakeWall / CameraLimitArea.queue_free()
        $FakeWall.collision_enabled = false
    if Globals.get_flag("door_puzzle_intro2"):
        $FakeWall2.queue_free()
        $Lever3.active = true
    if hd_remaster:
        $Toriel.play("hd_remaster")
        $Toriel.scale = Vector2(0.5, 0.5)
        $Toriel / Textbox.position *= 2
        $Toriel / Textbox.scale *= 2

func _process(_delta):
    if $FakeWall.visible:
        for area in $FakeWall / Area2D.get_overlapping_areas():
            if area.visible and area.get_parent() is Player:
                $FakeWall.hide()
                $FakeWall / CameraLimitArea.queue_free()
                $FakeWall.collision_enabled = false
                $FakeWall / AudioStreamPlayer.play()
                Globals.set_flag("fakewall_puzzle_intro2", true)
    var flag = Globals.get_flag("tutoriel_prog", 0)
    if $Lever.active and flag < 2.2:
        $Spikes.active = false
        $Spikes2.active = false
        Globals.set_flag("tutoriel_prog", 2.2)
    if $Lever2.active and flag < 3:
        $Door / CollisionShape2D.set_deferred("disabled", true)
        $Door.hide()
        Globals.set_flag("tutoriel_prog", 3)
    if $Lever3.active and not Globals.get_flag("door_puzzle_intro2"):
        $FakeWall2.queue_free()
        Globals.set_flag("door_puzzle_intro2", true)
    $Toriel.flip_h = get_parent().find_child("Player").position.x < $Toriel.position.x

func _on_cutscene_trigger_start_cutscene(player):
    $Toriel / Textbox.set_talk_sound(toriel_talk)
    await $Toriel / Textbox.show_text(text[0])
    await get_tree().create_timer(0.5).timeout
    Globals.set_flag("tutoriel_prog", 2.1)
    player.unpause()

func _on_cutscene_trigger2_start_cutscene(player):
    $Toriel.position = Vector2(410, 197)
    if not hd_remaster:
        $Toriel.play("walk")
    var tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(510, 197), 1)
    await tween.finished
    if not hd_remaster:
        $Toriel.play("default")
    $Toriel / Textbox.set_talk_sound(toriel_talk)
    await $Toriel / Textbox.show_text(text[1])
    await get_tree().create_timer(0.5).timeout
    player.unpause()

func _on_cutscene_trigger3_start_cutscene(player):
    await $Toriel / Textbox.show_text(text[2])
    await get_tree().create_timer(0.5).timeout
    player.unpause()

func _on_cutscene_trigger4_start_cutscene(player):
    await $Toriel / Textbox.show_text(text[3])
    await get_tree().create_timer(0.5).timeout
    player.unpause()

func _on_cutscene_trigger5_start_cutscene(_player):
    if not hd_remaster:
        $Toriel.play("shocked")
    $AudioStreamPlayer.play()
    Globals.set_flag("toriel_dark_entrance", true)
