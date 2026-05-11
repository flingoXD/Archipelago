extends Boss

var charge_sfx = preload("res://sounds/kamehameha_charge.wav")
var blast_sfx = preload("res://sounds/kamehameha_blast.wav")

var speed = 50
var freq = 1

var osc_time = 0
var base_vel = Vector2.ZERO
var target_pos
var powering_up = false

const text = {
    "talk": [
        "This isn't even my final form!", 
        "It isn’t easy being this bishie!", 
        "Don’t go tsundere on me now!", 
        "You must be the antagonist!"
    ], 
    "cheer": [
        "Wait! Do you speak fluent reference?", 
        "I can feel the power coursing through my ribbons!", 
        "I'm reaching Super Crispy Mode 2k!!", 
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", 
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    ], 
    "threat": [
        "Hey! I don’t judge your headcanons!", 
        "You have no respect for the art form."
    ]
}

func _ready():
    initial_state = Idle
    super._ready()

func talk(act):
    if act == "cheer":
        if $Timer.is_stopped():
            if aggression == 2 and atk < 10:
                power_up()
            await $Textbox.show_text(text["cheer"][min(5 - aggression, 4)], 2)
            add_spare()

            return
        act = "talk"
    await $Textbox.show_text(text[act][randi() % len(text[act])], 2)

func check():
    do_check("Crispy Scroll", "Looking for someone who can match his enthusiasm.")

func power_up():
    $AnimatedSprite2D.play("power_up")
    $FlameAnimation.show()
    powering_up = true
    atk = 10
    $BlastAnimation / DamageHitbox.atk = 10
    $AudioStreamPlayer.play()
    await get_tree().create_timer(2).timeout
    $AnimatedSprite2D.play("default")
    powering_up = false
    speed = 80
    freq = 2

func damage(player_atk, left = false):
    super.damage(player_atk, left)
    if hp < max_hp * 0.5 and atk < 10:
        power_up()

func _process(delta):
    super._process(delta)
    if not powering_up and no_ai <= 0:
        animated_sprite_play_basic($AnimatedSprite2D)

func _physics_process(delta):
    if powering_up or no_ai > 0:
        $AnimatedSprite2D.rotation = 0
        osc_time = 0
        return
    osc_time += delta
    var temp_target_pos = Vector2(target.position.x + target_pos.x * sign(self.position.x - target.position.x), 200 + target_pos.y) if target and no_ai <= 0 else self.position
    var target_vel = (temp_target_pos - self.position).normalized() * speed * 2
    base_vel = 0.8 * base_vel + 0.2 * target_vel
    self.velocity = base_vel - Vector2(0, sin(osc_time * PI * freq)) * speed * 3
    $AnimatedSprite2D.rotation = cos(osc_time * PI * freq * 0.5) * 0.3
    move_and_slide()

func kamehameha_blast():
    no_ai = 2
    $BlastAnimation.show()
    $BlastAnimation.rotation = PI if target.position.x > self.position.x else 0.0
    $BlastAnimation.play("default")
    play_sound(charge_sfx)
    await get_tree().create_timer(0.5).timeout
    play_sound(blast_sfx)
    await get_tree().create_timer(0.1).timeout
    $BlastAnimation / DamageHitbox.show()
    await get_tree().create_timer(0.5).timeout
    $BlastAnimation / DamageHitbox.hide()
    await get_tree().create_timer(1).timeout
    $BlastAnimation.hide()

class Idle extends BossState:
    func start():
        lifetime = randf_range(3, 5) * (1.0 if boss.atk < 10 else 0.5)
        successors = [Kamehameha]
        boss.target_pos = Vector2(randi_range(40, 80), randi_range(-40, -80))

class Kamehameha extends BossState:
    var blast

    func start():
        lifetime = randf_range(3, 5)
        successors = [Idle]
        boss.target_pos = Vector2(randi_range(60, 100), -20 if randf() < 0.4 else 5)
        blast = boss.find_child("BlastAnimation")

    func process(delta):
        super.process(delta)
        if abs(boss.position.y - boss.target_pos.y - 200) <= 10\
and boss.no_ai <= (-1.0 if boss.atk < 10 else -0.5) and not boss.powering_up:
            boss.kamehameha_blast()
            boss.target_pos = Vector2(randi_range(60, 100), -20 if randf() < 0.4 else 5)
