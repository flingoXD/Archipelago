extends Level

var enemy_approaching = preload("res://music/enemy approaching.wav")
var flier_scene = preload("res://enemies/flier.tscn")
var penilla_scene = preload("res://enemies/penilla.tscn")
var rorrim_scene = preload("res://enemies/rorrim.tscn")

var enemy_count = 0

func _ready():
    if Globals.get_flag("secret_prog", 0) < 1:
        Globals.set_flag("secret_prog", 1)
    if Globals.get_flag("junk_pit_done"):
        $CutsceneTrigger.hide()
        $CameraLimitArea.hide()
        $CameraLimitArea2.hide()
        $CameraLimitArea3.hide()
        $Stalactite.collide_with_ground = true
        $Stalactite2.collide_with_ground = true
        $Stalactite3.collide_with_ground = true
    else:
        $FakeWall3.show()
        $FakeWall2.hide()
        $CameraLimitArea4.hide()
    if Globals.get_flag("junk_pit_lever1"):
        $Lever.active = true
        $Spikes / Spikes.active = false
        $Spikes / Spikes2.active = false
    if Globals.get_flag("junk_pit_lever2"):
        $Lever2.active = true
        for i in range(2, 14):
            $Spikes.get_child(i).active = false
    if Globals.get_flag("junk_pit_gauntlet"):
        $Sprite2D.hide()
        if Globals.has_ability("check"):
            $CutsceneTrigger2.hide()

func _on_cutscene_trigger_start_cutscene(_player):
    $FakeWall3.wall_break()
    $FakeWall2.show()
    $CameraLimitArea.hide()
    $CameraLimitArea2.hide()
    $CameraLimitArea3.hide()
    $CameraLimitArea4.show()
    $AudioStreamPlayer.play()
    $Stalactite.collide_with_ground = true
    $Stalactite2.collide_with_ground = true
    $Stalactite3.collide_with_ground = true

func _process(_delta):
    if $Lever.active and not Globals.get_flag("junk_pit_lever1"):
        Globals.set_flag("junk_pit_lever1", true)
        $Spikes / Spikes.active = false
        $Spikes / Spikes2.active = false
    if $Lever2.active and not Globals.get_flag("junk_pit_lever2"):
        Globals.set_flag("junk_pit_lever2", true)
        for i in range(2, 14):
            $Spikes.get_child(i).active = false

func _on_cutscene_trigger2_start_cutscene(player):
    if true:
        await get_parent().grant_ability("check")
        Globals.game_manager.ap_check_location("Act - Check")
    get_parent().play_stream()
    var enemy
    if Globals.get_enemy_flag("junk_pit_penilla2") == null:
        enemy = penilla_scene.instantiate()
        call_deferred("add_child", enemy)
        enemy.position = Vector2(780, 440)
        enemy.enemy_id = "junk_pit_penilla2"
        enemy.connect("death", arena_second_phase)
        enemy.connect("spared", arena_second_phase)
    else:
        arena_second_phase()
    if Globals.get_enemy_flag("junk_pit_flier2") == null:
        enemy = flier_scene.instantiate()
        call_deferred("add_child", enemy)
        enemy.position = Vector2(940, 300)
        enemy.enemy_id = "junk_pit_flier2"
        enemy.connect("death", arena_second_phase)
        enemy.connect("spared", arena_second_phase)
        enemy.modulate.a = 0
        enemy.talkable = false
        get_tree().create_tween().tween_property(enemy, "modulate", Color.WHITE, 1)
        await get_tree().create_timer(1.5).timeout
        enemy.talkable = true
    else:
        arena_second_phase()
    get_parent().play_stream(enemy_approaching)
    player.unpause()

func arena_second_phase():
    enemy_count += 1
    if enemy_count < 2:
        return
    await get_tree().create_timer(1).timeout
    $Sprite2D.shaking = true
    await get_tree().create_timer(2).timeout
    $Sprite2D.shaking = false
    $Sprite2D.hide()
    var enemy = rorrim_scene.instantiate()
    call_deferred("add_child", enemy)
    enemy.position = $Sprite2D.position
    enemy.enemy_id = "junk_pit_rorrim"
    enemy.connect("death", arena_finish)
    enemy.connect("spared", arena_finish)

func arena_finish():
    await get_tree().create_timer(1).timeout
    get_parent().play_stream(self.stream)
    Globals.set_flag("junk_pit_gauntlet", true)
