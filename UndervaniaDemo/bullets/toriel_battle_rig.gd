extends Node2D

const bullet_scene = preload("res://bullets/toriel_fire.tscn")
const column_scene = preload("res://bullets/toriel_column.tscn")
const wave_scene = preload("res://bullets/toriel_wave.tscn")

@onready var TYPE = bullet_scene.instantiate().TYPE
var DO_BULLET_CACHE = true

var player
var bullet_cache = []

func _ready():
    player = Globals.game_manager.find_child("Player")

func spawn_bullet(fire_type, pos, parameter = null, lifetime = 1.0):
    var bullet: DamageHitbox = bullet_cache.pop_back() if DO_BULLET_CACHE else null
    if bullet:
        bullet.request_ready()
    else:
        bullet = bullet_scene.instantiate()
        bullet.battle_rig = self
        bullet.player = player
    bullet.fire_type = fire_type
    bullet.position = pos
    bullet.parameter = parameter
    bullet.lifetime = lifetime
    add_child(bullet)
    return bullet

func _process(delta):
    if widow_ahh_emit:
        for i in WIDOW_AHH_AMOUNT * delta:
            spawn_bullet(TYPE.GROUND, Vector2(
                widow_ahh_emit + 2 * randf_range( - WIDOW_AHH_SPREAD, WIDOW_AHH_SPREAD), 
                $WidowAhhParticles.position.y + randf_range( - WIDOW_AHH_SPREAD, WIDOW_AHH_SPREAD)
            ), Vector2(10, -30))
    if drama_emit > 0:
        if $DramaParticles.emitting:
            Globals.game_manager.camera_shake(floor(drama_emit * 0.05))
        drama_count += drama_emit * delta
        while drama_count >= 1:
            drama_count -= 1
            var vel = Vector2(randf_range( - $DramaParticles.process_material.initial_velocity_max, - $DramaParticles.process_material.initial_velocity_min), 0)
            spawn_bullet(TYPE.BASIC, 
                Vector2($DramaParticles.position.x, randi_range(0, 240)), 
                vel.rotated(deg_to_rad(randf_range( - $DramaParticles.process_material.spread, $DramaParticles.process_material.spread))), 
            -640 / vel.x).avoid_player = true
    if toriel_emit > 0:
        toriel_emit -= delta
        toriel_spawn_time -= delta
        if toriel_spawn_time <= 0:
            toriel_spawn_time += 0.05
            toriel_dir_count -= 1
            if toriel_dir_count < 0:
                toriel_dir *= -1
                toriel_dir_count = randi_range(1, 10)
            spawn_bullet(TYPE.WAVE, 
                Vector2((arena_start + arena_end) * 0.5, -60), 
                Vector2(TORIEL_AMP * toriel_dir, TORIEL_WAVE), 
            8).time = fmod(toriel_emit * TORIEL_FREQ, 4)

const WIDOW_AHH_LENGTH = 0.2
const WIDOW_AHH_AMOUNT = 1200
const WIDOW_AHH_SPREAD = 10

@export var arena_start: int
@export var arena_end: int

var widow_ahh_emit

func widow_ahh_telegraph():
    $WidowAhhParticles.emitting = true

func widow_ahh():
    $BoomAudio.play()
    widow_ahh_emit = arena_end
    Globals.game_manager.camera_shake(5)
    var tween = get_tree().create_tween()
    tween.tween_property(self, "widow_ahh_emit", arena_start - 30, WIDOW_AHH_LENGTH)
    await tween.finished
    widow_ahh_emit = null

const ROARING_FRAUD_COUNT = 17
const ROARING_FRAUD_WAVES = 7
const ROARING_FRAUD_SPEED = 140

func roaring_fraud(pos, long = false):
    $BoomAudio.pitch_scale = randf_range(0.6, 1)
    $BoomAudio.play()
    Globals.game_manager.camera_shake(10 if long else 5)
    if long:
        $ColumnAudio.pitch_scale = randf_range(0.6, 1)
        $ColumnAudio.play()
    for i in range(ROARING_FRAUD_WAVES + (6 if long else 0)):
        for j in range(ROARING_FRAUD_COUNT):
            spawn_bullet(TYPE.BASIC, pos, ROARING_FRAUD_SPEED * Vector2.UP.rotated((j + i * 0.5 + 0.25) * PI * 2 / ROARING_FRAUD_COUNT)).avoid_player = player.hp <= 2
        await get_tree().create_timer(0.1).timeout

const DRAMA_INCREMENT = 35

var drama_emit = 0
var drama_count = 0

func increase_drama():
    player.wind -= DRAMA_INCREMENT
    if player.wind < -80:
        drama_emit += 10 if drama_emit == 0 else drama_emit
    if $DramaParticles.emitting:
        $DramaParticles.amount_ratio *= 1.6
        $DramaParticles.process_material.initial_velocity_min *= 1.3
        $DramaParticles.process_material.initial_velocity_max *= 1.3
    $DramaParticles.emitting = true

func end_drama():
    player.wind = 0
    drama_emit = 0
    $DramaParticles.emitting = false
    $DramaParticles.amount_ratio = 0.1
    $DramaParticles.process_material.initial_velocity_min = 80
    $DramaParticles.process_material.initial_velocity_max = 100
    if $WaveAudio.playing:
        var tween = get_tree().create_tween()
        tween.tween_property($WaveAudio, "volume_linear", 0, 2)
        await tween.finished
        $WaveAudio.stop()

func mini_drama(enraged = false):
    $WaveAudio.volume_linear = 0
    $WaveAudio.pitch_scale = randf_range(1, 1.4)
    get_tree().create_tween().tween_property($WaveAudio, "volume_linear", 1, 0.5)
    $WaveAudio.play()
    drama_emit = 200 if enraged else 100
    $DramaParticles.process_material.initial_velocity_min = 300 if enraged else 200
    $DramaParticles.process_material.initial_velocity_max = 360 if enraged else 250

var last_column = 0

func spawn_column(on_player = false):
    var column = column_scene.instantiate()
    for i in range(8):
        column.position.x = player.position.x + randi_range(-20, 20) + randi_range(0, 20) if on_player else remap(abs(randf() - randf()), 1, 0, arena_start + 10, arena_end - 10)
        if abs(column.position.x - last_column) >= 40:
            break
    column.position.y = 120
    column.player = player
    last_column = column.position.x
    add_child(column)

const WAVE_POS = [55, 125, 195, 265]

func spawn_asgore():
    for i in range(4):
        var wave = wave_scene.instantiate()
        wave.position = Vector2(WAVE_POS[i], randi_range(-100, 0))
        wave.do_sound = i == 0
        add_child(wave)

const TORIEL_AMP = 100
const TORIEL_FREQ = 1
const TORIEL_WAVE = 2

var toriel_emit = 0
var toriel_spawn_time = 0
var toriel_dir = 1
var toriel_dir_count = 0

func actual_toriel():
    $WaveAudio.volume_linear = 0
    get_tree().create_tween().tween_property($WaveAudio, "volume_linear", 1, 0.5)
    $WaveAudio.pitch_scale = randf_range(1, 1.4)
    $WaveAudio.play()
    toriel_emit = 4
    await get_tree().create_timer(toriel_emit).timeout
    var tween = get_tree().create_tween()
    tween.tween_property($WaveAudio, "volume_linear", 0, 3)
    await tween.finished
    $WaveAudio.stop()
