extends Boss

const SPEED = 60
const RADIUS = 128
const FREQ = 1

var target_vel = Vector2.ZERO
var first_hit = true
var not_feelin_it = false
var cooldown_mult:
    get():
        return 0.4 if aggression > 6 else 0.7 if aggression > 4 else 1.0

const text = [
    "nnnnnnggghhh.", 
    "just pluggin along...", 
    "i'm fine, thanks."
]
const spare_text = [
    "heh...", 
    "heh heh...", 
    [
        [
            "may i show you something?", 
            "let me try..."
        ], 
        [
            "i call it \"dapperblook\"", 
            "do you like it..."
        ]
    ], 
    "oh gee..."
]

func talk(act):
    match act:
        "talk":
            if aggression == 1:
                $Textbox.show_text("...", 2)
            else:
                $Textbox.show_text(text[randi() % len(text)], 2)
        "cheer":
            if aggression == 2:
                boss_state = Dapperblook.new()
                talkable = false
                await $Textbox.show_text(spare_text[2][0], 2)
                boss_state.tears = true
                $AnimatedSprite2D.play("dapperblook")
                await $AnimatedSprite2D.animation_finished
                boss_state.tears = false
                add_spare()
                await $Textbox.show_text(spare_text[2][1], 2)
                talkable = true
            elif aggression > 4:
                await $Textbox.show_text(text[randi() % len(text)], 2)
                add_spare()
            else:
                await $Textbox.show_text(spare_text[clamp(4 - aggression, 0, len(spare_text) - 1)], 2)
                add_spare()
        "threat":
            add_spare(aggression - 12)
            $Textbox.show_text("go ahead, do it.", 2)

func check():
    do_check("Napstablook", "oh, i'm REAL funny.")

func damage(_atk, _left = false):
    if first_hit:
        boss_state = Opening.new() if boss_state is Opening else Idle.new()
        $Textbox.show_text([
            "umm... you do know you cant kill ghosts, right?", 
            "we're sorta incorporeal and all"
        ], 2)
        first_hit = false

class Opening extends BossState:
    var nav_agent
    var osc_time = 0
    var base_vel = Vector2.ZERO

    func start():
        nav_agent = boss.find_child("NavigationAgent2D")
        on_navigation_timer_timeout()
        lifetime = 3 * boss.cooldown_mult
        successors = [TheReasonWhyIKeepDyingToNapstablook, ElderHu]

    func process(delta):
        super.process(delta)
        if nav_agent.is_navigation_finished():
            on_navigation_timer_timeout()

    func physics_process(delta):
        osc_time += delta
        if boss.no_ai <= 0:
            var next_pos = nav_agent.get_next_path_position()
            var dir = (next_pos - boss.global_position).normalized()
            boss.target_vel = dir * SPEED
        base_vel = base_vel * 0.9 + boss.target_vel * 0.1
        boss.velocity = base_vel + Vector2(0, sin(osc_time * PI * FREQ)) * SPEED

    func on_navigation_timer_timeout():
        nav_agent.target_position = Vector2(randi_range(80, 560), randi_range(80, 280))

class TheReasonWhyIKeepDyingToNapstablook extends Opening:
    var the_reason_why_i_keep_dying_to_napstablook = preload("res://bullets/the_reason_why_i_keep_dying_to_napstablook.tscn")
    var attack_cooldown = 0
    var attack_end
    var sprite

    func start():
        super.start()
        sprite = boss.find_child("AnimatedSprite2D")
        attack_end = randf_range(3, 5) * boss.cooldown_mult
        lifetime = attack_end + randf_range(3, 5)
        successors = [Idle]

    func process(delta):
        super.process(delta)
        attack_cooldown -= delta
        if attack_cooldown <= 0 and lifetime > attack_end:
            for x in [0, 5 if sprite.flip_h else -5]:
                var new = the_reason_why_i_keep_dying_to_napstablook.instantiate()
                boss.get_parent().add_child(new)
                new.position = boss.position + Vector2(x, -4)
                new.target = boss.target
            attack_cooldown = 0.4 * boss.cooldown_mult

class NotFeelinIt extends Opening:
    func start():
        super.start()
        lifetime = randf_range(8, 10) * boss.cooldown_mult
        boss.find_child("Textbox").show_text("really not feelin up to it right now. sorry", lifetime - 1)

class Idle extends Opening:
    func start():
        super.start()
        if randf() < 0.5 and not boss.not_feelin_it:
            successors = [NotFeelinIt]
            boss.not_feelin_it = true

class Dapperblook extends Idle:
    var napsta_bullet = preload("res://bullets/napsta_bullet.tscn")
    var tears = false
    var attack_cooldown = 0
    var sprite

    func start():
        super.start()
        sprite = boss.find_child("AnimatedSprite2D")
        lifetime = 30

    func process(delta):
        super.process(delta)
        attack_cooldown -= delta
        if attack_cooldown <= 0 and tears:
            for x in [0, 5 if sprite.flip_h else -5]:
                var new = napsta_bullet.instantiate()
                boss.get_parent().add_child(new)
                new.position = boss.position + Vector2(x, -4)
                new.velocity = Vector2(randf_range(-1, 1), -2).normalized() * new.SPEED
                new.acceleration = Vector2(0, -1)
            attack_cooldown = 0.3

class ElderHu extends BossState:
    var napsta_bullet = preload("res://bullets/napsta_bullet.tscn")
    var target_position
    var attack_cooldown = 0
    var sprite

    func start():
        super.start()
        sprite = boss.find_child("AnimatedSprite2D")
        lifetime = randf_range(8, 12)
        successors = [Idle]

    func process(delta):
        super.process(delta)
        attack_cooldown -= delta
        if attack_cooldown <= 0 and boss.position.y < 50:
            for x in [0, 5 if sprite.flip_h else -5]:
                var new = napsta_bullet.instantiate()
                boss.get_parent().add_child(new)
                new.position = boss.position + Vector2(x, -4)
                new.velocity = Vector2(randf_range(-1, 1), 1).normalized() * new.SPEED
            attack_cooldown = 0.3 * boss.cooldown_mult

    func physics_process(_delta):
        if not target_position or (target_position - boss.position).length_squared() < 1000:
            on_navigation_timer_timeout()
        var dir = (target_position - boss.position).normalized()
        dir.y *= 3
        boss.target_vel = dir * SPEED
        boss.velocity = boss.velocity * 0.9 + boss.target_vel * 0.1

    func on_navigation_timer_timeout():
        target_position = Vector2(randi_range(40, 280), -150 if lifetime > 3 else 70)

func _ready():
    super._ready()
    initial_state = Opening
    self.modulate.a = 0
    self.hide()

func _process(delta):
    super._process(delta)
    if target:
        $AnimatedSprite2D.flip_h = target.position.x > self.position.x

func start_animation():
    show()
    talkable = false
    var tween = get_tree().create_tween()
    tween.tween_property(self, "modulate", Color.WHITE, 1)
    await tween.finished
    talkable = true

func _on_navigation_timer_timeout():
    if boss_state and no_ai <= 0 and boss_state.has_method("on_navigation_timer_timeout"):
        boss_state.on_navigation_timer_timeout()

func do_flee(_hazard = false):
    super.do_flee()
    var tween = get_tree().create_tween().set_parallel()
    tween.tween_property(self, "velocity", Vector2.ZERO, 1)
    tween.tween_property(self, "modulate", Color(Color.TRANSPARENT), 1)
