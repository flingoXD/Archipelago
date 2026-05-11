extends Enemy

var bullet_scene = preload("res://bullets/moldsmal_attack.tscn")

var attack_cooldown = 0
var random_spare_time = 5

const text = [
    "Squorch...", 
    "Burble burb...", 
    "*Slime sounds*", 
    "*Sexy wiggle*"
]

func talk(_act):
    $Textbox.show_text(text[randi() % len(text)], 2)

func check():
    do_check("Moldsmal", "Stereotypical: Curvaceously attractive, but no brains...")

func _process(delta):
    super._process(delta)
    attack_cooldown -= delta
    animated_sprite_play_basic($AnimatedSprite2D)
    if target and no_ai <= 0:
        random_spare_time -= delta
        if attack_cooldown <= 0 and not spare_time:
            var bullet = bullet_scene.instantiate()
            bullet.linear_velocity = Vector2(randf_range(0.2, 0.8) * sign(target.position.x - self.position.x), -0.5).normalized() * 160
            bullet.big = true
            bullet.atk = self.atk
            get_parent().add_child(bullet)
            bullet.position = self.position + Vector2(0, -8)
            attack_cooldown = 4
    if random_spare_time <= 0 and not spare_time:
        do_spare()

func do_death():
    dropped_gold = 3
    super.do_death()
