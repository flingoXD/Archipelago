extends Level

var fallen_warrior = preload("res://music/fallen warrior.wav")

const text = [
    [
        "So many things in my way... still!", 
        "A human has come - I can hardly believe it.", 
        "But I do not know if they trust me... and I do not have my sword...", 
        "Is it even worth it? If I fail, there will be no need for another attempt.", 
        "No - I must persevere, if only to prove myself."
    ], 
    [
        "Ah, but the human is here again.", 
        "One so dedicated will be perfect for my plan."
    ], 
    [
        "I see you have followed me this far into the catacombs."
    ], 
    [
        "And you have already fought the silent sentinel below, and claimed his mark.", 
        "A good fellow, though peculiar in his own way.", 
        "But then we all are, are we not?", 
        "Come, jump across the gap. With those wings, it poses no threat.", 
        "But there is one favor I must ask of you."
    ], 
    [
        "But here, you meet an impassable barrier.", 
        "Before you can go any further this way, you must find some way across.", 
        "Some item, some sort of device for flight.", 
        "I am sure it will not be hard for you.", 
        "Once you have done that, there is one favor I must ask of you."
    ], 
    [
        "I was once a swordsman, you see. I fought in the ancient war.", 
        "But many years ago now, I lost my weapon.", 
        "It was in these ruins, at least.\nI do not know exactly where.", 
        "But if you see an old sword in a corner somewhere - perhaps rusty, perhaps broken...", 
        "Come find me, up on the parapets of the city."
    ], 
    [
        "Ah, you are here again, human.", 
        "You have overtaken me already, and I see the mark of the silent sentinel on your shoulders.", 
        "A good fellow, though peculiar in his own way.", 
        "But then we all are, are we not?", 
        "Anyway, there is one favor I must ask of you."
    ]
]

func _ready():
    if Globals.get_flag("secret_prog", 0) > 1:
        $CutsceneTrigger.hide()
        $CutsceneTrigger2.hide()
        $Strytax.hide()
        $CameraLimitArea.hide()
    if Globals.get_flag("dalv_room2_lever"):
        $Lever.active = true
        $Spikes.active = false
        $Spikes2.active = false

func _process(_delta):
    if $Lever.active and not Globals.get_flag("dalv_room2_lever"):
        Globals.set_flag("dalv_room2_lever", true)
        $Spikes.active = false
        $Spikes2.active = false

func _on_cutscene_trigger_start_cutscene(player):
    $CutsceneTrigger2.hide()
    get_parent().play_stream(fallen_warrior)
    await $Strytax / Textbox.show_text(text[0])
    await get_tree().create_timer(1).timeout
    await $Strytax / Textbox.show_text(text[1])
    $Strytax.flip_h = true
    await get_tree().create_timer(0.5).timeout
    await $Strytax / Textbox.show_text(text[2])
    if Globals.has_ability("glide"):
        await $Strytax / Textbox.show_text(text[3])
    else:
        await $Strytax / Textbox.show_text(text[4])
    await $Strytax / Textbox.show_text(text[5])
    await get_tree().create_timer(0.5).timeout
    $CameraLimitArea.hide()
    Globals.set_flag("secret_prog", 2)
    player.unpause()
    get_parent().play_stream(self.stream)

func _on_cutscene_trigger2_start_cutscene(player):
    $CutsceneTrigger.hide()
    get_parent().play_stream(fallen_warrior)
    await $Strytax / Textbox.show_text(text[6])
    await $Strytax / Textbox.show_text(text[5])
    await get_tree().create_timer(0.5).timeout
    $CameraLimitArea.hide()
    Globals.set_flag("secret_prog", 2)
    player.unpause()
    get_parent().play_stream(self.stream)
