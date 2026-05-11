extends Boss

var splat_sfx = preload("res://sounds/splat.wav")

var fleeing = false

const text = {
    "talk": [
        "Micro ribbit.", 
        "Croak, croak."
    ], 
    "cheer": [
        "Happy croak."
    ], 
    "threat": [
        "Cower, cower.", 
        "Growl."
    ]
}

func talk(act):
    await $Textbox.show_text(text[act].pick_random(), 2)
    if act == "cheer":
        add_spare()

func check():
    do_check("Micro Froggit", "Often falls through the cracks.")

func _ready():
    super._ready()
    initial_state = Bounce
    $DamageHitbox.hide()

func _process(delta):
    super._process(delta)
    if no_ai > 0:
        return
    for body in $Area2D.get_overlapping_bodies():
        if body is Player:
            if body.velocity.y > 50 and self.position.y - body.position.y > abs(self.position.x - body.position.x):
                self.damage(0.5)
                play_sound(splat_sfx)
                body.inv = 0.1

func _physics_process(delta):
    super._physics_process(delta)
    if fleeing:
        self.velocity.x = -200
        self.velocity.y += 2000 * delta
        if is_on_floor():
            self.velocity.y = -500
        if self.position.x < 0:
            self.queue_free()

func do_flee(hazard = false):
    if hazard:
        self.position = Vector2(400, 0)
    else:
        super.do_flee(hazard)

func death_cutscene():
    self.velocity = Vector2.ZERO

func spare_cutscene():
    $DamageHitbox.hide()
    inv = 100000
    fleeing = true

func start_animation():
    $DamageHitbox.show()

class Bounce extends BossState:
    var gravity

    func start():
        lifetime = 0.66667
        successors = [Bounce]
        gravity = randi_range(1000, 4000)
        var dest = Vector2(boss.target.position.x + randi_range(-100, 100) * boss.target.position.y * 0.005, 200)
        boss.velocity = (dest - boss.position - 0.5 * Vector2.DOWN * gravity * lifetime ** 2) / lifetime
        boss.velocity.x *= 2

    func process(delta):
        lifetime = 0 if boss.is_on_floor() else 1
        super.process(delta)

    func physics_process(delta):
        boss.velocity.y += gravity * delta
