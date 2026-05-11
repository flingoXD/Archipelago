extends Level

var toriel_talk = preload("res://sounds/toriel_talk.wav")
var fallen_down = preload("res://music/fallen down.wav")

const text = [
    "Oh!", 
    "Oh my goodness, you are back!", 
    [
        "I thought I would never see you again after you fell down that hole.", 
        "But here you are in front of me!"
    ], 
    [
        "And bursting out of the ground, no less!", 
        "Of all the ways to get here, I did not expect that."
    ], 
    "How did you get here, my child? Are you hurt?", 
    "Not a scratch... Impressive! But still...", 
    "There, there, I will heal you.", 
    "Who did this to you? You will get an apology.", 
    [
        "I should not have left you alone for so long.", 
        "It was irresponsible to try to surprise you like this."
    ], 
    [
        "I should not have let you out of my sight.", 
        "I hoped you would follow my instructions not to explore.", 
        "You must have slipped away when I was not looking."
    ], 
    [
        "Err...", 
        "Well, I suppose I cannot hide it any longer.", 
        "Come, small one!"
    ], 
    "Where on earth did you come from?", 
    "With those disgusting wings on your back...", 
    "Such a long way to walk on your little feet..."
]

var hd_remaster = Globals.get_persistent_flag("silly_shader") == "hd_remaster"

func _ready():
    if Globals.get_flag("door_puzzle_pitfall3"):
        $Door.queue_free()
    if Globals.get_flag("toriel_home_prog", 0) >= 1:
        $Toriel.hide()
        $CutsceneTrigger2.hide()
    if hd_remaster:
        $Toriel.play("hd_remaster")
        $Toriel.scale = Vector2(0.5, 0.5)
        $Toriel / Textbox.position *= 2
        $Toriel / Textbox.scale *= 2

func _on_cutscene_trigger_start_cutscene(_player):
    if find_child("FakeWall2"):
        $FakeWall2.queue_free()

func _on_cutscene_trigger2_start_cutscene(player):
    $CameraLimitArea.limit_left = 640
    $Toriel / Textbox.set_talk_sound(toriel_talk)
    get_parent().play_stream()
    await get_tree().create_timer(1).timeout
    $Toriel.flip_h = true
    await get_tree().create_timer(0.5).timeout
    if not hd_remaster:
        $Toriel.play("shocked")
    await $Toriel / Textbox.show_text(text[0])
    await get_tree().create_timer(1).timeout
    get_parent().play_stream(fallen_down)
    if not hd_remaster:
        $Toriel.play("default")
    await $Toriel / Textbox.show_text(text[1])
    if Globals.get_flag("toriel_dark_entrance") and not Globals.get_flag("toriel_scold"):
        await $Toriel / Textbox.show_text(text[2])
    await $Toriel / Textbox.show_text(text[11])
    if Globals.has_ability("glide"):
        await $Toriel / Textbox.show_text(text[12])
    else:
        await $Toriel / Textbox.show_text(text[13])
    if Globals.get_flag("fakewall_home_entrance") and player.flip_h == true:
        await $Toriel / Textbox.show_text(text[3])

    await $Toriel / Textbox.show_text(text[4])
    if player.hp == player.max_hp:
        await $Toriel / Textbox.show_text(text[5])
    elif player.hp > 2:
        await $Toriel / Textbox.show_text(text[6])
    else:
        await $Toriel / Textbox.show_text(text[7])
    if Globals.get_flag("tutoriel_complete"):
        await $Toriel / Textbox.show_text(text[8])
    else:
        await $Toriel / Textbox.show_text(text[9])
    await $Toriel / Textbox.show_text(text[10])
    if not hd_remaster:
        $Toriel.play("walk")
    $Toriel.flip_h = false
    var tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(650, 397), 1)
    await tween.finished
    $Toriel.hide()
    $CameraLimitArea.limit_left = null
    Globals.set_flag("toriel_home_prog", 1)
    get_parent().play_stream(stream)
    player.unpause()
