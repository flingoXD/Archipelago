extends Enemy

var bullet_scene = preload("res://bullets/rorrim_attack.tscn")

const SPEED = 30
const FREQ = 1

var osc_time = 0
var base_vel = Vector2.ZERO
var cheered = false
var attacking = false
var attack_time = randi_range(5, 10)

const text = {
    "talk": [
        "Better check for food in your teeth.", 
        "Yellow is the new black.", 
        "Who’s the fairest of them all?", 
        "Like what you see?"
    ], 
    "cheer": [
        "Smiles are never out of style."
    ], 
    "threat": [
        "You look horrible."
    ]
}

func talk(act):
    await $Textbox.show_text(text[act][randi() % len(text[act])], 2)
    if act == "cheer":
        cheered = true

func check():
    if cheered:
        var player = Globals.game_manager.find_child("Player")
        await do_check(player.player_name + "...?", "You look perfect!", player.atk - 10, player.def - 10)
        do_spare()
    else:
        do_check("Rorrim", "It’s missing something...")

func _physics_process(delta):
    osc_time += delta
    var target_pos = target.position + Vector2((1000 if spare_time else 100) * sign(self.position.x - target.position.x), -60) if target and no_ai <= 0 else self.position
    var target_vel = (target_pos - self.position).normalized() * SPEED
    base_vel = 0.8 * base_vel + 0.2 * target_vel
    self.velocity = base_vel + Vector2(0, sin(osc_time * PI * FREQ)) * SPEED * 3
    move_and_slide()

func _process(delta):
    super._process(delta)
    $AnimatedSprite2D.play("hurt" if hp < max_hp else "default")
    attack_time -= delta
    if attack_time <= 0:
        attack_time = randi_range(5, 10)
        attacking = not attacking
    if attacking and target and not spare_time and round(attack_time) != round(attack_time + delta):
        var bullet = bullet_scene.instantiate()
        self.add_sibling(bullet)
        bullet.position.x = target.position.x + randi_range(-60, 60)
        bullet.position.y = 300
