extends Boss

const SPEED = 60
const FREQ = 1.6

var osc_time = 0
var base_vel = Vector2.ZERO
var target_pos
var temp_target_pos
var attacking

const text = {
    "talk": [
        "I apologise.", 
        "I have no choice.", 
        "Forgive me.", 
        "For my brothers...", 
        "For my sisters...", 
        "For the queen..."
    ], 
    "cheer": [
        "If only...", 
        "Thanks, I'm trying."
    ], 
    "threat": [
        "No, please don't!", 
        "I'm trying my best...", 
        "Leave me alone!"
    ]
}

const spare_text = [
    "I can't bear this any more!", 
    "*sobs*"
]

func talk(act):
    var t = spare_text if aggression == 1 and act == "threat" else text[act]
    await $Textbox.show_text(t[randi() % len(t)], 2)
    if act == "threat":
        add_spare()

func check():
    do_check("Whimsdux", "A bit braver than Whimsun, but still can't take being threatened.")

func _ready():
    initial_state = Idle
    super._ready()
    if not Globals.has_ability("glide"):
        self.queue_free()

func _process(delta):
    super._process(delta)
    if not attacking and no_ai <= 0:
        animated_sprite_play_basic($AnimatedSprite2D)

func _physics_process(delta):
    if attacking or no_ai > 0:
        self.velocity = Vector2.ZERO
        base_vel = Vector2.ZERO
        return
    osc_time += delta
    temp_target_pos = target.position + Vector2(target_pos.x * sign(self.position.x - target.position.x), target_pos.y) if target and no_ai <= 0 else self.position
    var target_vel = (temp_target_pos - self.position).normalized() * SPEED * 2
    base_vel = 0.8 * base_vel + 0.2 * target_vel
    self.velocity = base_vel + Vector2(2 * sin(osc_time * FREQ), 3 * sin(osc_time * PI * FREQ)) * SPEED
    move_and_slide()

class Idle extends BossState:
    func start():
        lifetime = randf_range(2, 4)
        successors = [Idle]
        boss.target_pos = Vector2(80, -80)

    func process(delta):
        super.process(delta)
        successors = [PreBoomerang if boss.target else Idle]

class PreBoomerang extends BossState:
    func start():
        lifetime = 3
        successors = [Idle]
        boss.target_pos = Vector2(60, -60)

    func process(delta):
        super.process(delta)
        if boss.position.distance_squared_to(boss.temp_target_pos) <= 100:
            lifetime = 0
            successors = [Boomerang]

class Boomerang extends BossState:
    var bullet_scene = preload("res://bullets/whimsdux_attack.tscn")
    var arrow_sfx = preload("res://sounds/arrow.wav")
    var throwing = false
    var sprite

    func start():
        lifetime = 2
        successors = [Idle]
        boss.attacking = true
        sprite = boss.find_child("AnimatedSprite2D")
        sprite.play("windup")

    func end():
        boss.attacking = false

    func process(delta):
        super.process(delta)
        if not boss.target:
            lifetime = 0
            return
        if 1 < lifetime and lifetime < 1.5 and not throwing:
            throwing = true
            sprite.play("throw")
            var bullet = bullet_scene.instantiate()
            bullet.position = boss.position
            bullet.dest = boss.target.position
            boss.add_sibling(bullet)
            boss.play_sound(arrow_sfx)
        if lifetime < 0.5 and throwing:
            throwing = false
            sprite.play("windup")
