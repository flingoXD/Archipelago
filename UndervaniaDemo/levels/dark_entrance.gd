extends Level

var toriel_talk = preload("res://sounds/toriel_talk.wav")

const text = [
    "My child! Are you alright?", 
    "...I am afraid I cannot reach you.", 
    "Can you climb back up? Or perhaps there is another way?", 
    "Be very careful, many monsters are unfriendly towards humans.", 
    "Please... stay safe."
]

func _ready():
    if Globals.get_flag("tutoriel_prog", 0) > 3 or not Globals.get_flag("toriel_dark_entrance"):
        $CutsceneTrigger.hide()
    if Globals.game_manager.find_child("Player").position.y < 0:
        $InteractDoor2.hide()
        await get_tree().create_timer(2).timeout
        $InteractDoor2.show()

func _on_cutscene_trigger_start_cutscene(player):
    await get_tree().create_timer(2).timeout
    $Textbox.set_talk_sound(toriel_talk)
    await $Textbox.show_text(text)
    await get_tree().create_timer(0.5).timeout
    player.unpause()
