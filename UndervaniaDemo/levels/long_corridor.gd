extends Level

var toriel_talk = preload("res://sounds/toriel_talk.wav")
var tension = preload("res://music/unnecessary tension.wav")
var enemy_approaching = preload("res://music/enemy approaching.wav")
var impact = preload("res://sounds/impact.wav")
@export var usual_stream: AudioStream

var froggit_scene = preload("res://enemies/froggit.tscn")
var enemy_count = 0

const text = [
    [
        "You have done excellently thus far, my child.", 
        "As much as I would have liked to help you across that last puzzle...", 
        "You must learn to be independent and take care of yourself.", 
        "I have a difficult request to ask of you.", 
        "...", 
        "I would like you to walk to the end of the room by yourself.", 
        "Forgive me for this."
    ], 
    [
        "I am so sorry, I did not know they would attack you.", 
        "It is a good thing you were able to fend them off.", 
        "Thank you for trusting me, though.", 
        "Now I must attend to some business, and you must stay alone for a while.", 
        "Please remain here. It's dangerous to explore by yourself.", 
        "Be good, alright?"
    ], 
    [
        "Where did you go? I thought you were right behind me.", 
        "You should not have been exploring by yourself.", 
        "It is dangerous without my protection.", 
        "I have a difficult request to ask of you.", 
        "...", 
        "I would like you to walk to the end of the room by yourself.", 
        "Forgive me for this."
    ], 
    [
        "I am so sorry, I did not know they would attack you.", 
        "It is a good thing you were able to fend them off.", 
        "How did it take you so long to walk to the end of the corridor, though?", 
        "I know it is a long corridor, but it is not that long.", 
        "What were you doing while I was waiting here for you?", 
        "I must attend to some business now, and you must stay alone for a while.", 
        "Please remain here. It's dangerous to explore by yourself.", 
        "Be good, alright?"
    ]
]

var looping = true
var loop_threshold = 1840
var player
var arena_limit_left = 4560
var hd_remaster = Globals.get_persistent_flag("silly_shader") == "hd_remaster"

func get_stream():
    var flag = Globals.get_flag("tutoriel_prog", 0)
    if flag >= 6:
        return usual_stream
    elif flag >= 5.1:
        return tension
    else:
        return null

func _ready():
    var flag = Globals.get_flag("tutoriel_prog", 0)
    if flag >= 6:
        $Toriel.hide()
        $CutsceneTrigger.hide()
        $CutsceneTrigger2.hide()
        $CameraLimitArea / CollisionShape2D.set_deferred("disabled", true)
        looping = false
    elif flag >= 5.1:
        $Toriel.position.x = 2610
        $CutsceneTrigger.pause_player = false
        $Timer.start()
    for i in range(3):
        if Globals.get_flag("long_corridor_lever" + str(i + 1)):
            $Puzzle.get_child(i).active = true
            for j in range(3):
                $Puzzle.get_child(i * 3 + j + 3).active = false
    if hd_remaster:
        $Toriel.play("hd_remaster")
        $Toriel.scale = Vector2(0.5, 0.5)
        $Toriel / Textbox.position *= 2
        $Toriel / Textbox.scale *= 2

func _on_cutscene_trigger_start_cutscene(p):
    player = p
    if not $CutsceneTrigger.pause_player:
        return
    $Toriel / Textbox.set_talk_sound(toriel_talk)
    if Globals.get_flag("flowey3_done") and not Globals.get_flag("toriel_scold"):
        await $Toriel / Textbox.show_text(text[2])
        Globals.set_flag("toriel_scold", true)
    else:
        await $Toriel / Textbox.show_text(text[0])
    get_parent().play_stream(tension)
    $Timer.start()
    if not hd_remaster:
        $Toriel.play("walk")
    $Toriel.flip_h = false
    var tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(330, 197), 0.5)
    await tween.finished
    if not hd_remaster:
        $Toriel.play("default")
    $Toriel.position.x = 2610
    $Toriel.flip_h = true
    player.unpause()
    Globals.set_flag("tutoriel_prog", 5.1)

func _on_timer_timeout():
    looping = false

func _process(_delta):
    for i in range(3):
        if $Puzzle.get_child(i).active and not Globals.get_flag("long_corridor_lever" + str(i + 1)):
            Globals.set_flag("long_corridor_lever" + str(i + 1), true)
            for j in range(3):
                $Puzzle.get_child(i * 3 + j + 3).active = false

func _physics_process(_delta):
    if looping and player and player.position.x > loop_threshold:
        self.position.x += 320
        loop_threshold += 320
        limit_left += 640
        limit_right += 640
        arena_limit_left += 640
        $CameraLimitArea.limit_right += 640
        $HazardRespawn.respawn_position.x += 320
        $HazardRespawn2.respawn_position.x += 320

func _on_cutscene_trigger_2_start_cutscene(p):
    player = p
    get_parent().play_stream()
    var enemy = froggit_scene.instantiate()
    call_deferred("add_child", enemy)
    enemy.position = $Sprite2D2.position
    enemy.enemy_id = "long_corridor_froggit1"
    enemy.connect("death", arena_second_phase)
    enemy.connect("spared", arena_second_phase)
    await get_tree().create_timer(1.5).timeout
    # $StaticBody2D / CollisionShape2D.set_deferred("disabled", false)
    $StaticBody2D / CollisionShape2D2.set_deferred("disabled", false)
    $CameraLimitArea.limit_left = arena_limit_left
    get_parent().play_stream(enemy_approaching)
    player.unpause()

func arena_second_phase():
    enemy_count = 1
    var enemy = froggit_scene.instantiate()
    self.add_child(enemy)
    enemy.position = $Sprite2D.position
    enemy.enemy_id = "long_corridor_froggit2"
    enemy.connect("death", arena_finish)
    enemy.connect("spared", arena_finish)
    var enemy2 = froggit_scene.instantiate()
    self.add_child(enemy2)
    enemy2.position = $Sprite2D2.position
    enemy2.enemy_id = "long_corridor_froggit3"
    enemy2.connect("death", arena_finish)
    enemy2.connect("spared", arena_finish)

func arena_finish():
    enemy_count += 1
    if enemy_count < 3:
        return
    player.pause()
    player.velocity.x = 0
    get_parent().play_stream()
    # $StaticBody2D / CollisionShape2D.set_deferred("disabled", true)
    $StaticBody2D / CollisionShape2D2.set_deferred("disabled", true)
    if not hd_remaster:
        $Toriel.play("walk")
    var tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(2570, 197), 0.5)
    await tween.finished
    if not hd_remaster:
        $Toriel.play("default")
    $Toriel / Textbox.set_talk_sound(toriel_talk)
    if Globals.get_flag("flowey3_done") and not Globals.get_flag("toriel_scold"):
        await $Toriel / Textbox.show_text(text[3])
        Globals.set_flag("toriel_scold", true)
    else:
        await $Toriel / Textbox.show_text(text[1])
    $Toriel.flip_h = false
    if not hd_remaster:
        $Toriel.play("walk")
    tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(2610, 197), 0.5)
    await tween.finished
    if not hd_remaster:
        $Toriel.play("default")
    $Toriel.hide()
    Globals.set_flag("tutoriel_prog", 6)
    Globals.set_flag("tutoriel_complete", true)
    $CameraLimitArea / CollisionShape2D.set_deferred("disabled", true)
    Globals.save_game(self)
    get_parent().play_stream(usual_stream)
    player.unpause()
