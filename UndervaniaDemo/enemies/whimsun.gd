extends Enemy

const SPEED = 60
const RADIUS = 128

var target_vel = Vector2.ZERO
var random_spare_time = 5

const text = [
    "I'm sorry...", 
    "*sniff sniff*", 
    "I have no choice...", 
    "Forgive me..."
]

func talk(act):
    match act:
        "talk":
            $Textbox.show_text(text[randi() % len(text)], 2)
        "cheer":
            await $Textbox.show_text("*sobs*", 2)
            spare_time = -1
        "threat":
            await $Textbox.show_text("I can't handle this...", 2)
            dropped_gold = 2
            do_spare()

func check():
    do_check("Whimsun", "This monster is too sensitive to fight...")

func _process(delta):
    super._process(delta)
    animated_sprite_play_basic($AnimatedSprite2D)
    if $NavigationAgent2D.is_navigation_finished():
        _on_navigation_timer_timeout()
    if random_spare_time <= 0 and not spare_time:
        do_spare()

func _physics_process(delta):
    if target and no_ai <= 0:
        var next_pos = $NavigationAgent2D.get_next_path_position() * 0.5
        var dir = (next_pos - self.global_position * 0.5).normalized()
        target_vel = dir * SPEED
        random_spare_time -= delta
    else:
        target_vel = Vector2.ZERO
    self.velocity = self.velocity * 0.8 + target_vel * 0.2
    move_and_slide()

func _on_navigation_timer_timeout():
    if not target:
        return
    if spare_time:
        $NavigationAgent2D.target_position = self.global_position * 2 - target.global_position
        return
    for i in range(16):
        var rot = randf() * 2 * PI
        $NavigationAgent2D.target_position = target.global_position + Vector2(cos(rot), sin(rot)) * RADIUS
        if $NavigationAgent2D.is_target_reachable():
            return

func do_death():
    if dropped_xp > 0:
        dropped_gold = 2
    super.do_death()
