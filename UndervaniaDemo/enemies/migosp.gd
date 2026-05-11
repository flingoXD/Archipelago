extends Enemy

const bullet_scene = preload("res://bullets/minigosp.tscn")

const GRAVITY = 800
const SPEED = 100

var happy = 0
var move_time = 0
var move_cooldown = 1
var attack_cooldown = 2

const text = [
    "FILTHY SINGLE MINDER...", 
    "OBEY THE OVERMIND...", 
    "LEGION! WE ARE LEGION!", 
    "HEED THE SWARM!", 
    "IN UNISON, NOW!"
]

const spare_text = [
    "Bein' me is the best!", 
    "La la~ Just be yourself~", 
    "Nothin' like alone time!", 
    "Mmm, cha cha cha!", 
    "Swing your arms, baby!"
]

func talk(act):
    match [act, happy > 1]:
        ["cheer", true]:
            await $Textbox.show_text("Hiya~", 2)
        ["talk", false]:
            await $Textbox.show_text(text.pick_random(), 2)
        [_, true]:
            await $Textbox.show_text(spare_text.pick_random(), 2)
        _:
            await $Textbox.show_text("I DON'T CARE.", 2)

func check():
    do_check("Migosp", "It seems evil, but it's just with the wrong crowd...")

func _process(delta):
    super._process(delta)
    if not spare_time:
        happy += delta
        for body in $DetectionRange2.get_overlapping_bodies():
            if body is Enemy and body != self:
                happy = 0
    if happy > 1:
        $GPUParticles2D.hide()
        $AnimatedSprite2D.flip_h = false
        if happy > 6.4:
            do_spare()
            $AnimatedSprite2D.play("happy")
        elif happy > 3:
            $AnimatedSprite2D.play("dance")
        else:
            $AnimatedSprite2D.play("happy")
    else:
        $GPUParticles2D.show()
        if self.velocity.x == 0:
            animated_sprite_play_basic($AnimatedSprite2D)
        attack_cooldown -= delta
        if target and no_ai <= 0 and attack_cooldown <= 0 and is_on_floor()\
and abs(target.position.x - self.position.x) < 100:
            attack_cooldown = 2 + randf() * 2
            move_cooldown = randf() + 1
            $AnimatedSprite2D.flip_h = target.position.x > self.position.x
            spawn_attack()

func _physics_process(delta):
    move_cooldown -= delta
    move_time -= delta
    if move_time <= 0:
        self.velocity.x = 0
    if target and no_ai <= 0 and move_cooldown <= 0 and happy <= 1 and is_on_floor():
        var right = target.position > self.position
        if randf() < 0.3:
            right = not right
        self.velocity.x = SPEED * (1 if right else -1)
        move_time = randf_range(0.5, 1)
        move_cooldown = move_time + randf()
        $AnimatedSprite2D.play("walk")
        $AnimatedSprite2D.flip_h = right
    self.velocity.y += GRAVITY * delta
    move_and_slide()

func spawn_attack():
    for i in [-1, 0, 1]:
        var bullet = bullet_scene.instantiate()
        add_sibling(bullet)
        bullet.position = self.position
        bullet.velocity = Vector2((target.position.x - self.position.x + randf_range(-20, 20) + i * 60) / bullet.TIME, -0.5 * bullet.GRAVITY * bullet.TIME ** 2)
