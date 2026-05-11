extends Level

var godhome = load("res://levels/godhome.tscn")
var arrow_sfx = preload("res://sounds/arrow.wav")
var cymbal_sfx = preload("res://sounds/cymbal.wav")
var giygas_sfx = preload("res://sounds/giygas.wav")
var barrier = preload("res://music/barrier.wav")

var hidden_platforms = []

func _ready():
    $CameraLimitArea2.hide()
    for i in range(6):
        var platform = $Rubble.find_child("BrokenPlatform" + str(i + 1))
        hidden_platforms.append(platform)
        $Rubble.remove_child(platform)
    $ClingSpots.hide()
    $Strytax.shadow_amulet = null
    $Strytax.start_fight.call_deferred()

func exit():
    await get_tree().create_timer(2).timeout
    Globals.game_manager.level_transition(godhome, Vector2(30, 107.5), 0)

func spawn_platforms():
    if len(hidden_platforms) == 0:
        return
    $CameraLimitArea2.show()
    for platform in hidden_platforms:
        platform.find_child("Sprites").hide()
        platform.collision_layer = 0
        $Rubble.add_child(platform)
        platform._on_timer_timeout()
        await get_tree().create_timer(0.2).timeout
    hidden_platforms = []

func _on_cutscene_trigger2_start_cutscene(_player):
    while not is_instance_of($Strytax.boss_state, $Strytax.WallCling):
        await get_tree().create_timer(0.2).timeout
    $Strytax.start_third_phase()
    $CameraLimitArea3.limit_bottom = -4720
    $Hazard2.show()

func barrier_cutscene():
    var player = get_parent().find_child("Player")
    var rendezvous = Vector2(($Strytax.position.x + player.position.x) * 0.5, -2480)
    $Strytax.play_animation("spin_jump")
    $Strytax.flip_h = player.position.x < $Strytax.position.x
    player.flip_h = player.position.x > $Strytax.position.x
    var tween = get_tree().create_tween().set_parallel()
    tween.tween_property($Strytax, "position", rendezvous, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
    tween.tween_property($Strytax, "rotation", $Strytax.rotation + 30 * (-1 if $Strytax.flip_h else 1), 1)
    tween.tween_property(player, "position", rendezvous, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
    await tween.finished
    $Strytax.play_animation("infinity")
    $Strytax.rotation = - PI * 0.5
    $Strytax.play_sound(arrow_sfx)
    $Strytax.play_sound(cymbal_sfx)
    player.velocity = Vector2.ZERO
    var time = cymbal_sfx.get_length()
    var old_limit = $CameraLimitArea3.limit_bottom
    tween = get_tree().create_tween().set_parallel()
    tween.tween_property($Strytax, "position", Vector2(rendezvous.x, -2650), time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
    tween.tween_property($CameraLimitArea3, "limit_bottom", -4920, time)
    tween.tween_property($EscapeLight, "modulate", Color.WHITE, time)
    await tween.finished
    $Strytax.play_sound(giygas_sfx)
    $Strytax.play_animation("zap")
    await get_tree().create_timer(giygas_sfx.get_length()).timeout
    $CameraLimitArea3.limit_bottom = old_limit
    $GodRays2.hide()
    $Parallax2D2 / Barrier.show()
    get_parent().play_stream(barrier)
    get_tree().create_tween().tween_property($EscapeLight, "modulate", Color.TRANSPARENT, 2)
