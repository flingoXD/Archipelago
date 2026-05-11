extends Control

var heart_shard = preload("res://objects/heart_shard.tscn")
var determination = preload("res://music/determination.wav")
var game_manager_scene = load("res://game_manager.tscn")
var asgore_talk = preload("res://sounds/asgore_talk.wav")
var asriel_talk = preload("res://sounds/asriel_talk.wav")

const text = [
    "You cannot give up just yet...", 
    "Our fate rests on you...", 
    "It cannot end now!", 
    "Don't lose hope!", 
    "You're going to be alright!"
]

const asriel_text = [
    [", this is just a bad dream...", "Wake up! It's not over!"], 
    ["! It's like he says...", "You have to stay determined!"], 
    ["! Please don't give up...", "Have some determination..."], 
    ["! Come on!", "You can't quit! Stay determined..."], 

    [", it's not time to leave!", "Hold on! You can do this!"], 

    [", you have to keep going.", "Stay determined!"]
]

func _ready():
    $Heart.texture.region.position.x = 0
    $GameOver.modulate.a = 0
    show()
    $Heart.show()
    await get_tree().create_timer(0.5).timeout
    $Heart.texture.region.position.x = 20
    $AudioBreak1.play()
    await get_tree().create_timer(1.5).timeout
    $Heart.hide()
    $AudioBreak2.play()
    for i in range(6):
        var shard = heart_shard.instantiate()
        self.add_child(shard)
        shard.linear_velocity = 200 * Vector2.from_angle(randf_range(0, 2 * PI))
        shard.position = $Heart.position + 0.5 * $Heart.size
    await get_tree().create_timer(1.5).timeout
    $MusicPlayer.play(determination)
    var tween = get_tree().create_tween()
    tween.tween_property($GameOver, "modulate", Color.WHITE, 1)
    if Globals.get_flag("kills", 0) > 0:
        $Textbox.set_talk_sound(asgore_talk)
        await $Textbox.show_text([
            text.pick_random(), 
            Globals.get_persistent_flag("player_name", "Chara") + "! Stay determined!"
        ])
    else:
        $Textbox.set_talk_sound(asriel_talk)
        var t = asriel_text.pick_random()
        await $Textbox.show_text([Globals.get_persistent_flag("player_name", "Chara") + t[0], t[1]])
    tween.kill()
    $MusicPlayer.fade_out()
    tween = get_tree().create_tween()
    tween.tween_property($GameOver, "modulate", Color.TRANSPARENT, 1)
    await tween.finished
    var game_manager: GameManager = game_manager_scene.instantiate()
    game_manager.start_level = ""
    add_sibling(game_manager)
    queue_free()
