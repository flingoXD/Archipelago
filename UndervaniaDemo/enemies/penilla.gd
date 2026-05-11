extends Enemy

var impact = preload("res://sounds/impact.wav")
var bullet_scene = preload("res://bullets/penilla_attack.tscn")

const GRAVITY = 800
const SPEED = 100
const JUMP_SPEED = 250
const LUNGE_SPEED = 400

var talk_count = 0
var attack_cooldown = 0
var actual_cooldown = 0
var fall_time = 0
var attack_dest:
    set(val):
        attack_dest = val
        if val:
            self.velocity = self.position.direction_to(val) * LUNGE_SPEED
var saved_target_pos

enum STATE{NORMAL, UPDASH, HOVER, LUNGE}
var state: STATE:
    set(val):
        match val:
            STATE.NORMAL:
                attack_cooldown = 0.5 + randf() * 1
                actual_cooldown = 2 + randf() * 2
                saved_target_pos = null
                attack_dest = null
                self.velocity = Vector2.ZERO
            STATE.HOVER:
                attack_dest = null
                actual_cooldown = 0.5
                self.velocity = Vector2.ZERO
                $AnimatedSprite2D.play("hover")
            STATE.LUNGE:
                attack_dest = saved_target_pos
                actual_cooldown = 100
                $AnimatedSprite2D.play("lunge")
            STATE.UPDASH:
                actual_cooldown = 100
                $AnimatedSprite2D.play("jump")
        state = val

const text = {
    "talk": [
        "Gotta keep my skills sharp!", 
        "The artist’s life is one of solitude.", 
        "So all my handiwork leads to this?", 
        "2B or not 2B?"
    ], 
    "cheer": [
        "You’re just saying that cause you feel obligated.", 
        "I don't really think it's ready for people yet."
    ]
}

const spare_text = [
    "I suppose I could use a break.", 
    "I have been at this for a while..."
]

func talk(act):
    talk_count += 1
    var spare = talk_count >= 3 or act == "threat"
    var t = spare_text if spare else text[act]
    await $Textbox.show_text(t[randi() % len(t)], 2)
    if spare:
        do_spare()

func check():
    do_check("Penilla", "A sketchy character.")

func _process(delta):
    super._process(delta)
    attack_cooldown -= delta
    actual_cooldown -= delta

    if not is_on_floor():
        match state:
            STATE.HOVER:
                if actual_cooldown <= 0:
                    state = STATE.LUNGE
                    var bullet = bullet_scene.instantiate()
                    bullet.target = self
                    add_sibling(bullet)
                    bullet.position = self.position
            STATE.UPDASH:
                if self.position.distance_to(attack_dest) < 5 or is_on_ceiling():
                    state = STATE.HOVER
    elif target and no_ai <= 0 and attack_cooldown <= 0 and state == STATE.NORMAL:
        var right = target.global_position > self.global_position
        if spare_time:
            right = not right
        if actual_cooldown <= 0 and start_attack():
            right = saved_target_pos > self.position
        else:
            if randf() < 0.3:
                right = not right
            self.velocity.x = (SPEED + randf() * 50) * (1 if right else -1)
            self.velocity.y = - JUMP_SPEED
        if $AnimatedSprite2D.flip_h != right:
            $LungeHitbox.scale.x = -1
            $RayCast2D.target_position.x = - $RayCast2D.target_position.x
        $AnimatedSprite2D.flip_h = right
        attack_cooldown = 0.5 + randf() * 1
        $AnimatedSprite2D.play("jump")
    else:
        animated_sprite_play_basic($AnimatedSprite2D)
    $LungeHitbox.visible = $AnimatedSprite2D.animation == "lunge"

func _physics_process(delta):
    if state == STATE.NORMAL:
        self.velocity.y += GRAVITY * delta
    if not is_on_floor():
        fall_time += delta
    elif fall_time > 0:
        if fall_time > 1:
            play_sound(impact)
        fall_time = 0
        if self.velocity.x != 0:
            self.velocity.x = 0
    if state == STATE.LUNGE and (is_on_floor() or is_on_ceiling() or is_on_wall()):
        state = STATE.NORMAL
    move_and_slide()

func start_attack():
    attack_dest = self.position + $ShapeCast2D.target_position
    if $ShapeCast2D.is_colliding():
        attack_dest = get_parent().to_local($ShapeCast2D.get_collision_point(0)) + $CollisionShape2D.shape.size * 0.5
        attack_dest.x = self.position.x
        attack_dest.y += 10
        if self.position.y - attack_dest.y < 20:
            attack_dest = null
            return false
    if spare_time:

        return false
    saved_target_pos = target.position
    $ShapeCast2D2.position = attack_dest - self.position
    $ShapeCast2D2.target_position = saved_target_pos - attack_dest
    $ShapeCast2D2.force_shapecast_update()
    if $ShapeCast2D2.is_colliding():

        saved_target_pos = self.position + Vector2(randi_range(60, 120) * (randi_range(0, 1) * 2 - 1), 0)
        $ShapeCast2D2.target_position = saved_target_pos - attack_dest
        $ShapeCast2D2.force_shapecast_update()
        if $ShapeCast2D2.is_colliding():

            saved_target_pos = get_parent().to_local($ShapeCast2D2.get_collision_point(0)) + $CollisionShape2D.shape.size * 0.5
            if self.position.distance_to(saved_target_pos) < 20:

                attack_dest = null
                saved_target_pos = null
                return false
    state = STATE.UPDASH
    return true
