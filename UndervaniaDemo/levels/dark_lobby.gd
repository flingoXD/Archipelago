extends Level

var flier_scene = preload("res://enemies/flier.tscn")
var enemy_approaching = preload("res://music/enemy approaching.wav")
var penilla_scene = preload("res://enemies/penilla.tscn")

var enemy_count = 0

func _ready():
    if Globals.get_flag("dark_lobby_gauntlet"):
        $CutsceneTrigger.hide()
        $StaticBody2D / CollisionShape2D.set_deferred("disabled", true)
        $StaticBody2D / CollisionShape2D2.set_deferred("disabled", true)

func _on_cutscene_trigger_start_cutscene(_player):
    get_parent().play_stream()
    $CameraLimitArea.show()
    var enemy = flier_scene.instantiate()
    call_deferred("add_child", enemy)
    enemy.position = Vector2(130, 80)
    enemy.enemy_id = "dark_lobby_flier1"
    enemy.connect("death", arena_second_phase)
    enemy.connect("spared", arena_second_phase)
    enemy.modulate.a = 0
    enemy.talkable = false
    get_tree().create_tween().tween_property(enemy, "modulate", Color.WHITE, 1)
    $StaticBody2D / CollisionShape2D.set_deferred("disabled", false)
    $StaticBody2D / CollisionShape2D2.set_deferred("disabled", false)
    await get_tree().create_timer(1.5).timeout
    enemy.talkable = true
    get_parent().play_stream(enemy_approaching)

func arena_second_phase():
    enemy_count = 1
    var enemy = flier_scene.instantiate()
    self.add_child(enemy)
    enemy.position = Vector2(70, 60)
    enemy.enemy_id = "dark_lobby_flier2"
    enemy.connect("death", arena_third_phase)
    enemy.connect("spared", arena_third_phase)
    enemy.modulate.a = 0
    enemy.talkable = false
    get_tree().create_tween().tween_property(enemy, "modulate", Color.WHITE, 1)
    var enemy2 = flier_scene.instantiate()
    self.add_child(enemy2)
    enemy2.position = Vector2(250, 60)
    enemy2.enemy_id = "dark_lobby_flier3"
    enemy2.connect("death", arena_third_phase)
    enemy2.connect("spared", arena_third_phase)
    enemy2.modulate.a = 0
    enemy2.talkable = false
    get_tree().create_tween().tween_property(enemy2, "modulate", Color.WHITE, 1)
    await get_tree().create_timer(1).timeout
    enemy.talkable = true
    enemy2.talkable = true

func arena_third_phase():
    enemy_count += 1
    if enemy_count < 3:
        return
    await get_tree().create_timer(1).timeout
    var enemy = penilla_scene.instantiate()
    self.add_child(enemy)
    enemy.position = $Sprite2D.position
    enemy.enemy_id = "dark_lobby_penilla"
    enemy.connect("death", arena_finish)
    enemy.connect("spared", arena_finish)

func arena_finish():
    await get_tree().create_timer(1).timeout
    get_parent().play_stream(self.stream)
    $StaticBody2D / CollisionShape2D.set_deferred("disabled", true)
    $StaticBody2D / CollisionShape2D2.set_deferred("disabled", true)
    $CameraLimitArea.hide()
    Globals.set_flag("dark_lobby_gauntlet", true)
