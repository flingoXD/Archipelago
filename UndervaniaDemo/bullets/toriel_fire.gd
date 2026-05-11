extends DamageHitbox

var smoke_scene = preload("res://bullets/toriel_smoke_single.tscn")

const AVOID_DIST = 20
const AVOID_FORCE = 10000
const WAVE_VEL = Vector2(0, 100)

enum TYPE{BASIC, GROUND, WAVE}




@export var fire_type: TYPE
@export var parameter: Vector2
@export var lifetime = 1.0

var velocity
var accel
var time
var avoid_player
var battle_rig

func _ready():
    super._ready()
    match fire_type:
        TYPE.BASIC:
            velocity = parameter
            accel = 0
        TYPE.GROUND:
            velocity = Vector2(randf_range( - parameter.x, parameter.x), 0)
            accel = parameter.y
        TYPE.WAVE:
            velocity = WAVE_VEL
            accel = 0
    time = 0
    lifetime += randf_range(-0.5, 0)
    avoid_player = false
    self.modulate = Color.ORANGE_RED
    if player:
        atk = ceil(3 + 5 * player.hp / player.max_hp)

func _process(delta):
    super._process(delta)
    if player:
        atk = ceil(3 + 5 * player.hp / player.max_hp)
    var color_phase = 2 * time / lifetime
    self.modulate = lerp(Color.ORANGE, Color.LIGHT_GOLDENROD, color_phase - 1) if color_phase > 1\
else lerp(Color.ORANGE_RED, Color.ORANGE, color_phase)

func _physics_process(delta):
    if time == 0 and player and player.hp <= 2 and not avoid_player:
        self.despawn()
        return
    time += delta
    if time > lifetime:
        self.despawn()
        return
    velocity.y += accel * delta
    self.position += velocity * delta
    if fire_type == TYPE.WAVE:
        self.position.x += sin(time * PI / parameter.y) * parameter.x * delta
    if not player:
        return
    if avoid_player:
        var perp_dist = (player.position - self.position).slide(velocity.normalized())
        self.position -= perp_dist.normalized() * delta * AVOID_FORCE * exp( - perp_dist.length_squared() / AVOID_DIST ** 2)
    elif player.hp <= 2:
        var smoke = smoke_scene.instantiate()
        smoke.position = self.position
        smoke.velocity = Vector2(randf_range(-10, 10), randf_range(-10, 10))
        add_sibling(smoke)
        self.despawn()

func despawn():
    if battle_rig.DO_BULLET_CACHE:
        battle_rig.bullet_cache.append(self)
        battle_rig.remove_child(self)
    else:
        self.queue_free()
