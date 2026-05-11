extends Enemy

const ACCEL = 1000
const MAX_SPEED = 300
const GRAVITY = 960
const JUMP_SPEED = 300

var attack_cooldown = 0
var rolling = -1
var bouncing = false
var roll_dir = 0

const text = [
    "Please don't pick on me.", 
    "Quit staring at me.", 
    "I've got my eye on you.", 
    "Don't point that at me.", 
    "What an eyesore."
]

func talk(act):
    match act:
        "talk":
            $Textbox.show_text(text[randi() % len(text)], 2)
        "cheer":
            if dropped_xp > 4:
                dropped_xp -= 2
            await $Textbox.show_text("Finally someone gets it.", 2)
            do_spare()
        "threat":
            if dropped_xp < 20:
                dropped_xp += 5
            await $Textbox.show_text("You rude little snipe!", 2)

func check():
    do_check("Loox", "Don't pick on him. Family name: Eyewalker")

func _process(delta):
    super._process(delta)
    attack_cooldown -= delta
    rolling -= delta
    if target and no_ai <= 0 and attack_cooldown <= 0:
        attack_cooldown = 2.5
        rolling = 1.2
        roll_dir = sign(target.position.x - self.position.x)
        $AnimatedSprite2D.play("roll")
        bouncing = randi_range(0, 1) == 1




    if rolling > -0.4:
        $AnimatedSprite2D.rotation = clamp(rolling, 0, 1) * 4 * PI * - roll_dir
        if rolling <= 0:
            no_ai = max(no_ai, 0.1)
            $AnimatedSprite2D.play("roll_exit")
    else:
        $AnimatedSprite2D.rotation = 0
        animated_sprite_play_basic($AnimatedSprite2D)

func _physics_process(delta):
    if rolling > 0:
        self.velocity.x = clamp(self.velocity.x + ACCEL * delta * roll_dir, - MAX_SPEED, MAX_SPEED)
        if is_on_floor() and bouncing:
            self.velocity.y = - JUMP_SPEED
    else:
        if abs(self.velocity.x) < ACCEL * delta:
            self.velocity.x = 0
        else:
            self.velocity.x -= ACCEL * delta * roll_dir
    self.velocity.y += GRAVITY * delta
    move_and_slide()
