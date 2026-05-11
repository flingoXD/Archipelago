extends Level

var your_best_friend = preload("res://music/your best friend.wav")
var flowey_talk = preload("res://sounds/flowey_talk.wav")
var flowey_talk_evil = preload("res://sounds/flowey_talk_evil.wav")

func get_stream():
    stream.stream_mask = 3 if Globals.get_flag("flowey3_done") else 1
    return stream

func _ready():
    if Globals.get_flag("flowey3_done"):
        $CutsceneTrigger.hide()
        $CutsceneTrigger2.hide()
        $Flowey.hide()

func _on_cutscene_trigger_start_cutscene(player, upper = false):
    $CutsceneTrigger.hide()
    $CutsceneTrigger2.hide()
    get_parent().play_stream(your_best_friend)
    $Flowey / Textbox.set_talk_sound(flowey_talk)
    var prog = Globals.get_flag("tutoriel_prog", 0)
    if prog <= 4:
        await $Flowey / Textbox.show_text("Wow, you really are eager to get away from her, aren'tcha?")
        if prog <= 3:
            await $Flowey / Textbox.show_text([
                "You just couldn't wait till she'd gone before you set off your own way.", 
                "Instead, you disobeyed her, and flipped the switch she told you specifically not to flip..."
            ])
            if Globals.get_flag("toriel_dark_entrance"):
                await $Flowey / Textbox.show_text("And did it right in front of her, before her very eyes!")
            if prog < 3:
                await $Flowey / Textbox.show_text("You couldn't even be bothered to flip the ones she wanted you to flip first!")
        else:
            await $Flowey / Textbox.show_text("No sooner had she turned her back, than you immediately crept away and escaped.")
        await $Flowey / Textbox.show_text([
            "Honestly, I'm proud of you.", 

            "But there's still one thing that bothers me."
        ])
    elif prog < 6:
        await $Flowey / Textbox.show_text([
            "Howdy! What a pleasant surprise.", 
            "Took you a little while, but you went back and tried that third lever eventually.", 
        ])
        if prog < 5:
            await $Flowey / Textbox.show_text([
                "Was it seriously just that frog?", 
                "I can't believe you couldn't figure out how to kill one monster.", 
                "Don't bother with the ACT that old lady showed you. Just two quick hits and that thing's dead.", 
            ])
        elif prog == 5:
            await $Flowey / Textbox.show_text([
                "Couldn't you figure out how to get past those spikes and enter the next room?", 
                "The pattern is literally drawn out on the floor."
            ])
        else:
            await $Flowey / Textbox.show_text([
                "Don't tell me you couldn't manage to run down a hallway. Even a toddler like you can figure that out.", 
                "And in case you were wondering, yes it does loop, but only for a while.", 
                "I guess whoever wrote the music thought it was so cool they wanted everyone to hear the entire thing.", 
                "Idiot."
            ])
        await $Flowey / Textbox.show_text("But there is one other thing that bothers me.")
    else:
        await $Flowey / Textbox.show_text("What a sucker.")
        if not upper:
            await $Flowey / Textbox.show_text([
                "You didn't want to upset your nice goat mom, so instead...", 
                "...you went through her entire tutorial and only came back later.", 
                "Or did you just forget this was here?"
            ])
        elif Globals.get_flag("fakewall_puzzle_intro2"):
            await $Flowey / Textbox.show_text([
                "You found another way out, a way of escaping that old lady.", 
                "But you didn't want to upset your nice goat mom, so instead...", 
                "...you went through her entire tutorial without a second thought.", 
                "You didn't even come back for it later!", 
                "Instead you found a completely different way of getting here."
            ])
        else:
            await $Flowey / Textbox.show_text([
                "You were so into that old lady's tutorial, that you didn't even look for another way.", 
                "Or you were just too stupid to see the cracks in the wall.", 
                "Instead you went through the whole thing without a second thought...", 
                "And got here the much more obvious way."
            ])
        await $Flowey / Textbox.show_text([
            "Honestly, I have nothing to say.", 
            "Have fun exploring the rest of this stupid place."
        ])
        $Flowey.offset.y = -2
        $Flowey.play("sink")
        await $Flowey.animation_finished
        $Flowey.hide()
        await get_tree().create_timer(0.5).timeout
        player.unpause()
        get_parent().play_stream(stream)
        Globals.set_flag("flowey3_done", true)
        return
    await $Flowey / Textbox.show_text([
        "How did you know where the lever was and what it would do?", 
        "Perhaps you just noticed the cracks, or the suspiciously room-shaped wall.", 
        "Or perhaps you were just hitting random walls and happened to come across one which broke.", 
        "But that's not the case, is it?"
    ])
    get_parent().play_stream(null, false)
    $Flowey / Textbox.set_talk_sound(flowey_talk_evil)
    $Flowey.play("evil")
    await get_tree().create_timer(1).timeout
    await $Flowey / Textbox.show_text([
        "[shake rate=20.0 level=5]You knew what happened to the last human who came here.[/shake]", 
        "[shake rate=20.0 level=5]You knew there was a third lever all along.[/shake]", 
        "I bet you feel really proud of yourself right now.", 
        "You thought, \"Surely this won't work? Surely she fixed it up by now?\"", 
        "But she didn't, did she?", 
        "You were able to escape the linear path she wanted you to follow.", 
        "With all your determination, you were able to choose your own way.", 
        "Well, let me tell you something.", 
        "You may take many paths on your way, but in the end...", 
        "[shake rate=20.0 level=5]What you want don't really matter.[/shake]", 
        "[shake rate=20.0 level=5]There's only one way out of the underground, and there's only one way out of these ruins.[/shake]", 
        "Little old Gun-hat only went a different way because I let them.", 
        "[shake rate=20.0 level=5]You'll never be able to go that way even if you try.[/shake]", 
        "The places have changed, the people have moved on.", 
        "There's only one way to go, and that's through Toriel.", 
        "[shake rate=20.0 level=5]And you've got to kill her... or be killed.[/shake]"
    ])
    await get_tree().create_timer(1).timeout
    get_parent().play_stream(your_best_friend)
    $Flowey / Textbox.set_talk_sound(flowey_talk)
    $Flowey.play("left")
    await $Flowey / Textbox.show_text([
        "Now, if you just head up there to the left, you might be able to catch up with her before she leaves.", 
        "You can continue her little tutorial like normal, and we can all pretend this never happened."
    ])
    if not Globals.has_ability("talk"):
        await $Flowey / Textbox.show_text("Perhaps you'll learn something incredibly important from her!\nHee hee.")
    await $Flowey / Textbox.show_text("If not, though...")
    get_parent().play_stream(null, false)
    await get_tree().create_timer(0.5).timeout
    await $Flowey / Textbox.show_text([
        "Don't worry, I won't kill you - not just yet.", 
        "This might turn out to be very interesting."
    ])
    $Flowey.offset.y = -19.5
    $Flowey.play("grow")
    await $Flowey.animation_finished
    $Flowey.play("laugh")
    $Flowey / Laugh.play()
    await $Flowey / Laugh.finished
    $Flowey.play("shrink")
    await $Flowey.animation_finished
    $Flowey.offset.y = -2
    $Flowey.play("sink")
    await $Flowey.animation_finished
    $Flowey.hide()
    await get_tree().create_timer(0.5).timeout
    stream.stream_mask = 3
    get_parent().play_stream(stream)
    player.unpause()
    Globals.set_flag("flowey3_done", true)

func _on_cutscene_trigger2_start_cutscene(player):
    _on_cutscene_trigger_start_cutscene(player, true)
