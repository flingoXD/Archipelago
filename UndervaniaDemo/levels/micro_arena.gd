extends Level

var croak_sfx = preload("res://sounds/micro_croak.wav")

var boss_fight = 0
var player

func _ready():
    if Globals.get_enemy_flag("micro_froggit") == null:
        $CameraLimitArea.hide()
    else:
        $CutsceneTrigger.hide()
        boss_fight = 2
        $Platform.position = Vector2.ZERO

func _on_cutscene_trigger_start_cutscene(p):
    player = p
    boss_fight = 1
    get_parent().play_stream()
    get_parent().find_child("MusicPlayer").set_wind(0)
    var tween = get_tree().create_tween()
    tween.tween_property(player, "light_override", 1, 2)
    await tween.finished
    $MicroFroggit.play_sound(croak_sfx)
    await get_tree().create_timer(0.5).timeout
    $MicroFroggit.play_sound(croak_sfx)
    await get_tree().create_timer(1).timeout
    $MicroFroggit.start_fight()
    player.unpause()
    $StaticBody2D / CollisionShape2D.set_deferred("disabled", false)

func _on_micro_froggit_death():
    Globals.set_flag("micro_prog", 5)
    $StaticBody2D / CollisionShape2D.set_deferred("disabled", true)
    await get_tree().create_timer(2).timeout
    var tween = get_tree().create_tween().set_parallel()
    tween.tween_property(player, "light_override", self.light_override, 5)
    await get_tree().create_timer(1).timeout
    get_parent().play_stream(self.stream)
    get_parent().find_child("MusicPlayer").set_wind(1)
    $CameraLimitArea.show()
    create_tween().tween_property($Platform, "position", Vector2.ZERO, 4)

func _on_micro_froggit_spared():
    _on_micro_froggit_death()
