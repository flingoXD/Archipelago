extends Level

var opening_attack = preload("res://bullets/decibat_stalactite.tscn")

var boss_fight = 0
var player

func _ready():
    if Globals.get_enemy_flag("decibat") != null:
        $CutsceneTrigger.hide()
        $Platform.position = Vector2.ZERO
        boss_fight = 2
    if not Globals.has_ability("glide"):
        $EnemyNPC.queue_free()

func _process(_delta):
    if boss_fight == 0:
        player = player if player else get_parent().find_child("Player")
        player.light_override = 0.5 - 0.0004 * clamp(player.position.x, 0, 1000)

func _on_cutscene_trigger_start_cutscene(p):
    player = p
    boss_fight = 1
    get_parent().play_stream()
    get_parent().find_child("MusicPlayer").set_wind(0)
    for i in range(5):
        var bullet = opening_attack.instantiate()
        call_deferred("add_child", bullet)
        bullet.position.x = player.position.x + randi_range(20, 120) * (randi_range(0, 1) * 2 - 1)
        bullet.position.y = -120 + randi_range(-40, 40)
    await get_tree().create_timer(2).timeout
    $CameraLimitArea.limit_bottom = 280
    $Decibat.start_fight()
    player.unpause()
    var tween = get_tree().create_tween().set_parallel()
    tween.tween_property($Parallax2D2, "modulate", Color.TRANSPARENT, 2)
    tween.tween_property(player, "light_override", 1, 2)

func _on_decibat_death():
    var tween = get_tree().create_tween().set_parallel()
    tween.tween_property($Parallax2D2, "modulate", Color("#f4ccff"), 5)
    tween.tween_property(player, "light_override", self.light_override, 5)
    get_parent().play_stream(self.stream)
    get_parent().find_child("MusicPlayer").set_wind(1)
    await get_tree().create_timer(1).timeout
    $CameraLimitArea.limit_bottom = 720
    create_tween().tween_property($Platform, "position", Vector2.ZERO, 8)
    Globals.set_flag("decibat_platform", true)

func _on_decibat_spared():
    await get_tree().create_timer(3).timeout
    _on_decibat_death()
