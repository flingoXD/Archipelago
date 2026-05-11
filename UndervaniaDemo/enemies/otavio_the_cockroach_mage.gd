extends Enemy

const GRAVITY = 800
const SPEED = 100

var move_time = 0
var move_cooldown = 1
var talk_count = 0

func talk(_act):
    match talk_count:
        0:
            await $Textbox.show_text("I AM OTAVIO THE COCKROACH MAGE", 2)
        4:
            await $Textbox.show_text("CALL THE MAGULANCE", 2)
            do_spare()
        _:
            var out = Array("I AM OTAVIO THE COCKROACH MAGE".split(" "))
            out.shuffle()
            await $Textbox.show_text(" ".join(out), 2)
    talk_count += 1

func check():
    do_check("Otavio", "It seems to be having a stronk.")

func _process(delta):
    super._process(delta)
    if self.velocity.x == 0:
        animated_sprite_play_basic($AnimatedSprite2D)

func _physics_process(delta):
    move_cooldown -= delta
    move_time -= delta
    if move_time <= 0:
        self.velocity.x = 0
    if no_ai <= 0 and move_cooldown <= 0 and is_on_floor():
        var right = randf() < 0.5
        self.velocity.x = SPEED * (1 if right else -1)
        move_time = randf_range(0.5, 1)
        move_cooldown = move_time + randf()
        $AnimatedSprite2D.play("walk")
        $AnimatedSprite2D.flip_h = right
    self.velocity.y += GRAVITY * delta
    move_and_slide()
