extends Enemy

var bullet_scene = preload("res://bullets/veg_attack.tscn")

const SPEED = 160

var hiding = true
var burrowing = true:
    set(val):
        burrowing = val
        transition = true
        $AnimatedSprite2D.play("burrow_start" if val else "burrow_end")
        $DamageHitbox.visible = not val
var burrow_time = 0
var transition = false
var check_count = 0
var greens_time = 0

var move_dir = 1

const text = [
    "Farmed Locally, Very Locally", 
    "Part Of A Complete Breakfast", 
    "Fresh Morning Taste", 
    "Contains Vitamin A", 
    "Plants Can't Talk Dummy"
]

func talk(act):
    match act:
        "cheer":
            $Textbox.show_text("Eat Your Greens", 2)
            greens_time = 10
        _:
            $Textbox.show_text(text[randi() % len(text)], 2)

func check():
    check_count += 1
    if check_count == 2:
        do_check("Vegetoid", "USDA stands for Underground Salad Demon Association.")
    else:
        do_check("Vegetoid", "Serving Size: 1 Monster.\nNot monitored by the USDA.")

func damage(player_atk, left = false):
    if transition or not burrowing:
        super.damage(player_atk, left)

func _ready():
    super._ready()
    $GPUParticles2D.show()

func _process(delta):
    super._process(delta)
    greens_time -= delta
    talkable = not burrowing and not transition
    burrow_time -= delta
    if burrow_time <= 0 and no_ai <= 0 and not transition and ( not hiding if burrowing else target):
        burrowing = not burrowing
        burrow_time = randf_range(3, 10) if burrowing else randf_range(2, 4)
        if not burrowing and not spare_time:
            spawn_bullets()
    if target and no_ai <= 0:
        if hiding:
            hiding = false
            burrowing = false
            burrow_time = randf_range(2, 4)
            spawn_bullets()
    if not transition:
        if burrowing:
            $AnimatedSprite2D.play("burrow")
        else:
            $AnimatedSprite2D.play("default")
    $GPUParticles2D.emitting = burrowing and not transition and not hiding

func _physics_process(_delta):
    if transition and target:
        move_dir = sign(target.position.x - self.position.x)
        if spare_time:
            move_dir = - move_dir
    if move_dir == -1 and ($Raycasts / WallLeft.is_colliding() or not $Raycasts / FloorLeft.is_colliding()):
        move_dir = 1
    if move_dir == 1 and ($Raycasts / WallRight.is_colliding() or not $Raycasts / FloorRight.is_colliding()):
        move_dir = -1
    self.velocity = Vector2.ZERO
    if burrowing and burrow_time > 1 and not transition and not hiding:
        if target and not spare_time and abs(target.position.x - self.position.x) < 10 and randf() < 0.05:
            burrow_time = 1
        else:
            self.velocity.x = move_dir * SPEED
    move_and_slide()

func do_death():
    dropped_gold = 1
    super.do_death()

func _on_animated_sprite_2d_animation_finished():
    transition = false

func spawn_bullets():
    for i in range(3):
        var bullet = bullet_scene.instantiate()
        bullet.linear_velocity = Vector2(randf_range(-0.8, 0.8), -1).normalized() * 240
        get_parent().add_child(bullet)
        bullet.position = self.position + Vector2(0, -8)
        if greens_time > 0 and (i == 0 or randf() < 0.2):
            bullet.green = true
            bullet.source = self

func eat_greens():
    await get_tree().create_timer(1).timeout
    do_spare()
