extends Level

var toriel_talk = preload("res://sounds/toriel_talk.wav")
var anticipation = preload("res://music/anticipation.wav")

const text = [
    [
        "As a human living in the UNDERGROUND, monsters may attack you.", 
        "You will need to be prepared for this situation.", 
        "However, worry not! The process is simple.", 
        "When you are engaged in a FIGHT, try to strike up a friendly conversation.", 
        "Stall for time.\nI will come to resolve the conflict.", 
        "Practice talking to this dummy."
    ], 
    [
        "Ahh, the dummies are not for fighting!\nThey are for talking.", 
        "We do not want to hurt anybody, now do we?"
    ], 
    [
        "...", 
        "...you ran away...", 
        "Truthfully, that was not a poor choice.", 
        "It is better to avoid conflict whenever possible.", 
        "That, however, is only a dummy.\nIt cannot harm you.", 
        "It is made of cotton.\nIt has no desire for revenge..."
    ], 
    [
        "...", 
        ".........", 
        "...the next room awaits."
    ], 
    [
        "Ah, very good! You are very good."
    ], 
    [
        "Thank goodness you are here!", 
        "Are you hurt? Where did you come from up there?", 
        "Ah well, it does not matter. You are safe now here with me.", 
        "Let us continue."
    ], 
    [
        "Where did you come from up there?", 
        "You should not have been exploring by yourself.", 
        "It is dangerous without my protection.", 
        "Thankfully you are safe now here with me.", 
        "Let us continue."
    ], 
    [
        "...", 
        "...you ran away...", 
        "Truthfully, that was not a poor choice.", 
        "It is better to avoid conflict whenever possible.", 
        "Although, you should not have been exploring by yourself.", 
        "It is dangerous without my protection."
    ]
]

var player
var hd_remaster = Globals.get_persistent_flag("silly_shader") == "hd_remaster"

func _ready():
    var prog = Globals.get_flag("tutoriel_prog", 0)
    if prog >= 4:
        if Globals.has_ability("talk"):
            $CutsceneTrigger.hide()
        else:
            $NotePaper.show()
        $Toriel.hide()
        $Toriel / StaticBody2D / CollisionShape2D.set_deferred("disabled", true)
        $Dummy.hide()
        if Globals.get_flag("dummy_defeat", 0) in [0, 2, 4]:
            $DummyNPC.show()
        self.stream.stream_mask |= 2 ** 7
        get_parent().play_stream(self.stream)
    elif prog == 3.1:
        $Dummy.hide()
        $DummyNPC.show()
    elif Globals.get_flag("toriel_dark_entrance"):
        $Toriel.flip_h = true
    if hd_remaster:
        $Toriel.play("hd_remaster")
        $Toriel.scale = Vector2(0.5, 0.5)
        $Toriel / Textbox.position *= 2
        $Toriel / Textbox.scale *= 2
        $Toriel / StaticBody2D.scale *= 2

func _on_cutscene_trigger_start_cutscene(p):
    player = p
    $Toriel / Textbox.set_talk_sound(toriel_talk)
    if Globals.get_flag("tutoriel_prog", 0) == 3.1:
        continue_cutscene(2)
        return
    elif Globals.get_flag("tutoriel_prog", 0) >= 4:
        await get_parent().grant_ability("talk")
        Globals.game_manager.ap_check_location("Act - Talk")
        player.unpause()
        return
    if Globals.get_flag("toriel_dark_entrance"):
        await get_tree().create_timer(1).timeout
        $Toriel.flip_h = false
        await get_tree().create_timer(0.5).timeout
        if not hd_remaster:
            $Toriel.play("shocked")
        await get_tree().create_timer(1).timeout
        if not hd_remaster:
            $Toriel.play("default")
        await $Toriel / Textbox.show_text(text[5])
        Globals.set_flag("toriel_scold", true)
    elif Globals.get_flag("fakewall_dummy_room"):
        await $Toriel / Textbox.show_text(text[6])
        Globals.set_flag("toriel_scold", true)
    else:
        await $Toriel / Textbox.show_text("Splendid! I am proud of you, little one.")
    await $Toriel / Textbox.show_text(text[0])
    if not hd_remaster:
        $Toriel.play("walk")
    $Toriel.flip_h = true
    var tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(14, 197), 0.5)
    await tween.finished
    if not hd_remaster:
        $Toriel.play("default")
    $Toriel.flip_h = false
    await get_tree().create_timer(0.5).timeout
    await get_parent().grant_ability("talk")
    Globals.game_manager.ap_check_location("Act - Talk")
    Globals.set_flag("tutoriel_prog", 3.1)
    get_parent().play_stream(anticipation)
    player.unpause()
    $Toriel / Timer.start()

func continue_cutscene(resolution):
    if resolution != 2:
        player.pause()
        $Toriel / Textbox.position.x = 40 if resolution == 3 else 70
    self.stream.stream_mask |= 2 ** 7
    get_parent().play_stream(self.stream)
    Globals.set_flag("dummy_defeat", resolution)
    Globals.set_flag("tutoriel_prog", 4)
    if resolution == 2 and Globals.get_flag("fakewall_dummy_room") and not Globals.get_flag("toriel_scold"):
        await $Toriel / Textbox.show_text(text[7])
        Globals.set_flag("toriel_scold", true)
    else:
        await $Toriel / Textbox.show_text(text[resolution])
    if not hd_remaster:
        $Toriel.play("walk")
    $Toriel.flip_h = true
    var tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(-10, 197), 1.0 if resolution == 2 else 0.3)
    await tween.finished
    $Toriel.hide()
    $Toriel / StaticBody2D / CollisionShape2D.set_deferred("disabled", true)
    player.unpause()

func _on_dummy_death():
    if Globals.get_flag("tutoriel_prog") == 3.1:
        continue_cutscene(1)

func _on_timer_timeout():
    if Globals.get_flag("tutoriel_prog") == 3.1:
        $AudioStreamPlayer.play()
        get_tree().create_tween().tween_property($Dummy, "position", Vector2(-10, 208), 1)
        continue_cutscene(3)

func _on_dummy_talked():
    if Globals.get_flag("tutoriel_prog") == 3.1:
        $Dummy.hide()
        $DummyNPC.show()
        continue_cutscene(4)
