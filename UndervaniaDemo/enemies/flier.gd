extends Enemy

const SPEED = 60
const FREQ = 1

var talked_to = false
var osc_time = 0
var base_vel = Vector2.ZERO

const text = {
    "talk": [
        "I’m looking to buy a boat! Know anyone selling?", 
        "I’ve been working out! No big deal ;)", 
        "I found this great new band the other day!", 
        "But I’m cool! I’m still cool!"
    ], 
    "cheer": [
        "That’s right! I knew you noticed!", 
        "Yeah, I totally agree."
    ], 
    "threat": [
        "You just have no sense of modern fashion trends!", 
        "That hurts me on a personal level."
    ]
}

const spare_text = [
    "I... this isn't really me...", 
    "You're right. Something needs to change."
]

func talk(act):
    var spare = spare_time or talked_to
    var t = spare_text if spare else text[act]
    talked_to = true
    await $Textbox.show_text(t[randi() % len(t)], 2)
    if spare:
        do_spare()

func check():
    do_check("Flier", "Flier feels nothing.")

func _process(delta):
    super._process(delta)
    animated_sprite_play_basic($AnimatedSprite2D)

func _physics_process(delta):
    osc_time += delta
    var target_vel = (target.position - self.position).normalized() * SPEED if target and no_ai <= 0 else Vector2.ZERO
    if spare_time:
        target_vel *= -1
    base_vel = 0.8 * base_vel + 0.2 * target_vel
    self.velocity = base_vel + Vector2(0, sin(osc_time * PI * FREQ)) * SPEED * 3
    move_and_slide()
