extends Enemy

var impact = preload("res://sounds/impact.wav")

const GRAVITY = 480
const SPEED = 160
const JUMP_SPEED = 300

var attack_cooldown = 0
var fall_time = 0

const text = {
    "talk": [
        "Ribbit, ribbit.", 
        "Croak, croak.", 
        "Hop, hop.", 
        "Meow."
    ], 
    "cheer": [
        "(Blushes deeply.) Ribbit..."
    ], 
    "threat": [
        "Shiver, shiver."
    ]
}

func talk(act):
    await $Textbox.show_text(text[act][randi() % len(text[act])], 2)
    do_spare()

func check():
    do_check("Froggit", "Life is difficult for this enemy.")

func _process(delta):
    super._process(delta)
    attack_cooldown -= delta
    if target and no_ai <= 0 and attack_cooldown <= 0 and is_on_floor():
        var right = target.global_position > self.global_position
        if spare_time:
            right = not right
        $AnimatedSprite2D.flip_h = right
        $JumpHitbox / CollisionShape2D.position.x = 6.5 if right else -6.5
        self.velocity.x = (SPEED + randf() * 50) * (1 if right else -1)
        self.velocity.y = - JUMP_SPEED
        attack_cooldown = 2 + randf() * 0.5
        $AnimatedSprite2D.play("jump")
        $JumpHitbox.show()
        $DamageHitbox.hide()

func _physics_process(delta):
    self.velocity.y += GRAVITY * delta
    if is_on_floor() and attack_cooldown < 2:
        if fall_time > 1:
            play_sound(impact)
        fall_time = 0
        if self.velocity.x != 0:
            self.velocity.x = 0
        $AnimatedSprite2D.play("left")
        $JumpHitbox.hide()
        $DamageHitbox.show()
    else:
        fall_time += delta
    move_and_slide()
