extends Level

var spikes_up = preload("res://sprites/spikes_up.png")
var spikes_down = preload("res://sprites/spikes_down.png")
var toriel_talk = preload("res://sounds/toriel_talk.wav")
var enemy_approaching = preload("res://music/enemy approaching.wav")
var impact = preload("res://sounds/impact.wav")
var flee = preload("res://sounds/flee.wav")

const text = [
    [
        "There is another puzzle in this room...", 
        "I wonder if you can solve it?"
    ], 
    [
        "Let us continue."
    ], 
    [
        "Ah, hello again!"
    ], 
    [
        "Where did you go? I thought you were right behind me.", 
        "You should not have been exploring by yourself.", 
        "It is dangerous without my protection."
    ]
]

var player
const GRAVITY = 960
var dest_x = 1000
var jump_time = 0
var floor_waiting = false
var hd_remaster = Globals.get_persistent_flag("silly_shader") == "hd_remaster"

signal dest_reached

func _ready():
    var flag = Globals.get_flag("tutoriel_prog", 0)
    if flag >= 5:
        $Toriel.hide()
        $CutsceneTrigger.hide()
        $CutsceneTrigger2.hide()
        $CutsceneTrigger3.hide()
        $FakeFroggit.hide()
        $CameraLimitArea.queue_free()
    elif flag >= 4.1:
        $Toriel.position = Vector2(670, 57)
        $CutsceneTrigger.hide()
    if Globals.get_flag("door_puzzle_intro3"):
        $Lever.active = true
        $FakeWall.hide()
        $FakeWall.collision_enabled = false
    if hd_remaster:
        $Toriel / AnimatedSprite2D.play("hd_remaster")
        $Toriel / AnimatedSprite2D.scale = Vector2(0.5, 0.5)

func _process(_delta):
    if $Lever.active and not Globals.get_flag("door_puzzle_intro3"):
        $FakeWall.hide()
        $FakeWall.collision_enabled = false
        $FakeWall / AudioStreamPlayer.play()
        Globals.set_flag("door_puzzle_intro3", true)

func _on_cutscene_trigger_start_cutscene(p):
    player = p
    $Toriel / Textbox.set_talk_sound(toriel_talk)
    if Globals.get_flag("flowey3_done") and not Globals.get_flag("toriel_scold"):
        await $Toriel / Textbox.show_text(text[2])
        await $Toriel / Textbox.show_text(text[3])
        Globals.set_flag("toriel_scold", true)
    await $Toriel / Textbox.show_text(text[0])
    $Toriel / AnimatedSprite2D.flip_h = true
    if not hd_remaster:
        $Toriel / AnimatedSprite2D.play("walk")
    var tween = get_tree().create_tween()
    tween.tween_property($Toriel, "position", Vector2(860, 197), 2)
    await tween.finished
    if not hd_remaster:
        $Toriel / AnimatedSprite2D.play("default")
    $Toriel / AnimatedSprite2D.flip_h = false
    $Toriel.position = Vector2(670, 57)
    await get_tree().create_timer(0.5).timeout
    Globals.set_flag("tutoriel_prog", 4.1)
    player.unpause()

func _on_cutscene_trigger_2_start_cutscene(p):
    player = p
    $Toriel / AnimatedSprite2D.flip_h = true
    if not hd_remaster:
        $Toriel / AnimatedSprite2D.play("walk")
    $Toriel.velocity.x = -150
    await reach(530)
    $Toriel.velocity = Vector2.ZERO
    if not hd_remaster:
        $Toriel / AnimatedSprite2D.play("default")
    $Toriel / AnimatedSprite2D.flip_h = false

func _on_cutscene_trigger_3_start_cutscene(p):
    player = p
    get_parent().play_stream()
    if not hd_remaster:
        $Toriel / AnimatedSprite2D.play("shocked")
    $CameraLimitArea.limit_right = 1520
    $FakeFroggit.show()
    var tween = get_tree().create_tween()
    tween.tween_property($FakeFroggit, "position", Vector2(670, 72), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    await tween.finished
    $FakeFroggit.play_sound(impact)
    await get_tree().create_timer(0.5).timeout
    get_parent().play_stream(enemy_approaching)
    $StaticBody2D / CollisionShape2D.set_deferred("disabled", false)
    $StaticBody2D / CollisionShape2D2.set_deferred("disabled", false)
    player.unpause()
    $FakeFroggit.target = player
    $Timer.start()

func continue_cutscene(killed = false):
    $Timer.stop()
    player.pause()
    player.velocity.x = 0
    Globals.set_enemy_flag("fake_froggit", killed)
    get_parent().play_stream()
    $Toriel / Textbox.position.x = 20
    $StaticBody2D / CollisionShape2D.set_deferred("disabled", true)
    $StaticBody2D / CollisionShape2D2.set_deferred("disabled", true)
    if killed:
        await get_tree().create_timer(1).timeout
        await $Toriel / Textbox.show_text("......")
        await get_tree().create_timer(0.5).timeout
        if not hd_remaster:
            $Toriel / AnimatedSprite2D.play("angry")
        if Globals.get_flag("flowey3_done") and not Globals.get_flag("toriel_scold"):
            await $Toriel / Textbox.show_text(".........")
    else:
        if not hd_remaster:
            $Toriel / AnimatedSprite2D.play("angry")
        $FakeFroggit.target = null
        $FakeFroggit.do_detect()
        await get_tree().create_timer(1).timeout
        $FakeFroggit / AnimatedSprite2D.flip_h = true
        $FakeFroggit.velocity.x = 150
        $FakeFroggit.gravity = 480
        $FakeFroggit.play_sound(flee)
        await get_tree().create_timer(2).timeout
        $FakeFroggit.hide()
        $FakeFroggit / DamageHitbox.hide()
        if not hd_remaster:
            $Toriel / AnimatedSprite2D.play("default")
        if Globals.get_flag("flowey3_done") and not Globals.get_flag("toriel_scold"):
            await $Toriel / Textbox.show_text(text[3])
    await $Toriel / Textbox.show_text(text[1])
    get_parent().play_stream(self.stream)
    if not hd_remaster:
        $Toriel / AnimatedSprite2D.play("walk")
    $Toriel / AnimatedSprite2D.flip_h = true
    $Toriel.velocity.x = -150
    await reach(430)
    $Toriel.velocity = Vector2.ZERO
    $Toriel.hide()
    await get_tree().create_timer(0.5).timeout
    Globals.set_flag("tutoriel_prog", 5)
    $CameraLimitArea.queue_free()
    player.unpause()

func _on_timer_timeout():
    if Globals.get_flag("tutoriel_prog") == 4.1:
        continue_cutscene()

func _on_fake_froggit_death():
    if Globals.get_flag("tutoriel_prog") == 4.1 and not $Timer.is_stopped():
        continue_cutscene(true)

func _on_fake_froggit_talked():
    await get_tree().create_timer(1).timeout
    if Globals.get_flag("tutoriel_prog") == 4.1 and not $Timer.is_stopped():
        continue_cutscene()

func reach(x):
    dest_x = x
    await dest_reached

func reach_floor():
    floor_waiting = true
    await dest_reached

func _physics_process(delta):
    if jump_time > 0:
        jump_time -= delta
        $Toriel.velocity.y = -320
    else:
        $Toriel.velocity.y += GRAVITY * delta
    $Toriel.move_and_slide()
    if $Toriel.position.x <= dest_x or $Toriel.is_on_floor() and floor_waiting:
        dest_reached.emit()
        floor_waiting = false
