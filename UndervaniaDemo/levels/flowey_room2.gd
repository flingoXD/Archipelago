extends Level

var your_best_friend = preload("res://music/your best friend.wav")
var flowey_talk = preload("res://sounds/flowey_talk.wav")
var flowey_talk_evil = preload("res://sounds/flowey_talk_evil.wav")
var wonderful_idea = preload("res://sounds/wonderful_idea.wav")

func _ready():
    if Globals.get_flag("flowey2_done"):
        $CutsceneTrigger.hide()
        $Flowey.hide()
    if Globals.get_flag("ruins_credits"):
        $CutsceneTrigger2.hide()
    else:
        $InteractDoor2.hide()

func _on_cutscene_trigger_start_cutscene(player):
    $CutsceneTrigger.hide()
    get_parent().play_stream(your_best_friend)
    $Flowey / Textbox.set_talk_sound(flowey_talk)
    var toriel_killed = Globals.get_enemy_flag("toriel")
    var toriel_kills = Globals.get_persistent_flag("toriel_kill_count", 0)
    var toriel_spares = Globals.get_persistent_flag("toriel_spare_count", 0)
    var flowey2_dones = Globals.get_persistent_flag("flowey2_done_count", 0)
    var genocide = Globals.get_flag("genocide")
    if genocide:
        await $Flowey / Textbox.show_text([
            "Hahaha...", 
            "You're not really human, are you?", 
            "No. You're empty inside. Just like me. In fact...", 
            "You're " + player.player_name + ", right?", 
            "We're still inseparable, after all these years..."
        ])
    elif not toriel_killed:
        await $Flowey / Textbox.show_text([
            "Clever. Verrrryyy clever.", 
            "You think you're really smart, don't you?", 
            "In this world..."
        ])
    elif toriel_kills > 2:
        await $Flowey / Textbox.show_text([
            "Wow, you really can't get enough.", 
            "You kind of remind me..."
        ])
    elif toriel_kills > 1:
        await $Flowey / Textbox.show_text([
            "Heheheheh.", 
            "You just can't get enough, can you!?", 
            "How many more times will you..."
        ])
    elif toriel_spares > 0:
        await $Flowey / Textbox.show_text([
            "Wow, you're utterly repulsive.", 
            "You spared her life...", 
            "Then you decided..."
        ])
    else:
        await $Flowey / Textbox.show_text([
            "Hee hee hee...", 
            "I hope you like your choice.", 
            "After all, it's not as if..."
        ])
    await get_tree().create_timer(1).timeout
    Globals.set_persistent_flag("flowey2_done_count", flowey2_dones + 1)
    if genocide:
        await $Flowey / Textbox.show_text([
            "Listen. I have a plan to become all powerful.", 
            "Even more powerful than you and your stolen soul.", 
            "Let's destroy everything in this wretched world.", 
            "Everyone, everything in these worthless memories...", 
            "Let's turn 'em all to dust."
        ])
        get_parent().play_stream()
        $Flowey.play("default")
        await get_tree().create_timer(0.5).timeout
        player.play_sound(wonderful_idea)
        await get_tree().create_timer(2.5).timeout
    elif flowey2_dones == 0:
        $Flowey.play("evil")
        $Flowey / Textbox.set_talk_sound(flowey_talk_evil)
        get_parent().play_stream(null, false)
        await $Flowey / Textbox.show_text([
            "No, you know what?", 
            "Something's very wrong here.", 
            "Whatever I do, you always seem to expect it.", 
            "Even now, your eyes betray you.", 
            "And yet we've never done any of this before.", 
            "Not in this world, or this universe."
        ])
        if Globals.get_persistent_flag("flowey1_hit") == false:
            await $Flowey / Textbox.show_text([
                "Even the very first time we met, you knew what I was about to do.", 
                "You saw my little trick, and dodged it perfectly."
            ])
        await $Flowey / Textbox.show_text([
            "So no, I'm not gonna give you the satisfaction of hearing me give my little speech.", 
            "I'm sure you know it all by heart already.", 
            "And I'm gonna figure out what on earth you are, and what your deal is."
        ])
    elif flowey2_dones == 1:
        $Flowey.play("evil")
        $Flowey / Textbox.set_talk_sound(flowey_talk_evil)
        get_parent().play_stream(null, false)
        await $Flowey / Textbox.show_text([
            "Hee hee... Come on.", 
            "How many times are you gonna make me do this?", 
            "Can't you be satisfied with just one?"
        ])
    else:
        await $Flowey / Textbox.show_text("I can't be bothered with this. Bye!")
    $Flowey.offset.y = -2
    $Flowey.play("sink")
    await $Flowey.animation_finished
    $Flowey.hide()
    await get_tree().create_timer(0.5).timeout
    get_parent().play_stream()
    player.unpause()
    Globals.set_flag("flowey2_done", true)

func _on_cutscene_trigger2_start_cutscene(player):
    await get_parent().show_credits()
    Globals.set_flag("ruins_credits", true)
    player.unpause()
    get_parent().level_transition($InteractDoor2.dest_scene, $InteractDoor2.entry_point, $InteractDoor2.left_facing)
