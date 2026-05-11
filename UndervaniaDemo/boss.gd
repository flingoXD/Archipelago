extends Enemy
class_name Boss

@export var boss_name: String
@export var boss_bar_color: Color = Color.WHITE
@export var aggression: int = 1
@export var boss_music: AudioStream
@export var end_music: AudioStream
@export var miniboss = false
@export var boss_bar_after_animation = false

var initial_state

var boss_fight = false
var boss_bar
var boss_state:
    set(val):
        if boss_state:
            boss_state.end()
        if val:
            val.predecessor = boss_state
        boss_state = val
        if val:
            val.boss = self
            val.start()

func _ready():
    super._ready()
    if miniboss:
        boss_fight = true
        if initial_state:
            boss_state = initial_state.new()

func start_fight():
    show()
    Globals.game_manager.play_stream(boss_music)
    if boss_bar_after_animation:
        await start_animation()
    boss_bar = Globals.game_manager.create_boss_bar(boss_name, boss_bar_color)
    boss_bar.max_value = max_hp
    boss_bar.value = hp
    if not boss_bar_after_animation:
        await start_animation()
    boss_fight = true
    target = Globals.game_manager.find_child("Player")
    if initial_state:
        boss_state = initial_state.new()

func start_animation():
    pass

func _process(delta):
    if not boss_fight:
        no_ai = 0.1
    super._process(delta)
    if boss_state and no_ai <= 0:
        boss_state.process(delta)

func _physics_process(delta):
    if boss_state and no_ai <= 0:
        boss_state.physics_process(delta)
    move_and_slide()

func damage(player_atk, left = false):
    var out = super.damage(player_atk, left)
    if boss_bar:
        boss_bar.value = hp
    return out

func add_spare(amount = 1, min_agg = 1, max_agg = 1000000):
    if spare_time or aggression < min_agg or aggression > max_agg:
        return
    aggression -= amount
    if amount != 0:
        play_sound(spare_sfx)
        var star = spare_star_scene.instantiate()
        if Globals.get_flag("pink_spare"):
            star.texture = star.pink_texture
        if amount < 0:
            star.texture = star.aggro_texture
        get_parent().add_child(star)
        star.position = self.position + Vector2(0, -20)
    if aggression <= 0:
        spare_time = 2 + randf() * 3
        self.material = pink_spare_shader if Globals.get_flag("pink_spare") else spare_shader

func do_flee(hazard = false):
    boss_fight = false
    inv = 2
    if not hazard:
        drop_gold()
    play_sound(vaporise_sfx)
    self.material = null
    if enemy_id and not hazard:
        Globals.set_enemy_flag(enemy_id, false)
    if not miniboss:
        Globals.game_manager.play_stream(end_music)
    if boss_bar:
        boss_bar.discard()
    await spare_cutscene()
    target = null
    spared.emit()
    if miniboss:
        var tween = get_tree().create_tween()
        tween.tween_property(self, "modulate", Color(self.modulate, 0), 1)
        await tween.finished
        self.queue_free()

func do_death():
    boss_fight = false
    inv = 1000
    if not miniboss:
        Globals.game_manager.play_stream(end_music)
    if boss_bar:
        boss_bar.discard()
    for node in self.find_children("*", "DamageHitbox"):
        node.collision_mask = 0
    await death_cutscene()
    super.do_death()

func death_cutscene():
    pass

func spare_cutscene():
    pass
