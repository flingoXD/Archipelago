extends Enemy

const SPEED = 250
const LAUNCH_SPEED = 500
const ACCEL = 0.98

var hiding = true

const text = {
    "talk": [
        "You're doing great, Sweetie!", 
        "*squeak* *squeak*", 
        "You can do this!", 
        "Remember, I always love you! <3"
    ], 
    "cheer": [
        "I love hugs! <3", 
        "I'm feelin' the love~"
    ], 
    "threat": [
        "W-whatever makes you happy.", 
        "Why aren't you happy?"
    ]
}

func talk(act):
    var t = text[act]
    await $Textbox.show_text(t[randi() % len(t)], 2)
    if act == "cheer":
        do_spare()

func check():
    do_check("Sweet Corn", "Constantly on a sugar high.")

func _ready():
    super._ready()
    $AnimatedSprite2D / DamageHitbox.atk = self.atk

func _process(delta):
    super._process(delta)
    animated_sprite_play_basic($AnimatedSprite2D)

func _physics_process(_delta):
    if target:
        $RayCast2D.target_position = target.position - self.position
    if target and no_ai <= 0 and not spare_time and not $RayCast2D.is_colliding():
        if hiding:
            hiding = false
            $AnimatedSprite2D / DamageHitbox.show()
            self.velocity = Vector2.UP * LAUNCH_SPEED
        self.velocity = self.velocity * ACCEL + (target.position - self.position).normalized() * SPEED * (1 - ACCEL)
        self.velocity = self.velocity.normalized() * (self.velocity.length() * ACCEL + SPEED * (1 - ACCEL))
        $AnimatedSprite2D.rotation = self.velocity.angle() + PI * 0.5
    else:
        self.velocity *= ACCEL
    move_and_slide()
