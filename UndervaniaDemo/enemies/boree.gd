




extends Enemy

@export var segment_count = 6
@export var armoured = true
@export var hiding = true

var segment_scene = preload("res://enemies/boree_segment.tscn")
var break_sfx = preload("res://sounds/platform_break.wav")
var switch_sfx = preload("res://sounds/switch.wav")

const SEGMENT_OFFSET = 10
const SPEED_MIN = 100
const SPEED_MAX = 400
const LAUNCH_SPEED = 200
const TURN_SPEED = 3
const ACCEL = 150
const GRAVITY = 600
const AERIAL_SPEED = 200

var spawn_point
var child
var fall_time = 0
var armour_broken
var threatened = false

const text = {
    "talk": [
        "Mmmmmmmmmm...", 
        "Aaaaaaaa...", 
        "Toot.", 
        "So you are a human, then?"
    ], 
    "cheer": [
        "Oh?", 
        "Haaaaaa...", 
        "Life down here is not so bad..."
    ], 
    "threat": [
        "..."
    ]
}

func talk(act):
    if act == "threat":
        if threatened:
            await $Textbox.show_text("Can't you just leave me alone?", 2)
            set_armoured(false)
            return
        threatened = true
    elif act == "cheer" and armour_broken:
        await $Textbox.show_text("Thank you, human, I shall go.", 2)
        do_spare()
        return
    await $Textbox.show_text(text[act].pick_random(), 2)

func check():
    if armoured:
        do_check("Boree", "The stalactite on its head protects it, but is easily broken.")
    elif armour_broken:
        do_check("Boree", "Now it's just sad that you broke its hat.")
    else:
        do_check("Boree", "A member of the chthonic choir. Hasn't seen the light in a long time.")

func get_segment_origin():
    return self.position - self.velocity.normalized() * SEGMENT_OFFSET

func _ready():
    super._ready()
    $AnimatedSprite2D / DamageHitbox.atk = self.atk
    spawn_point = self.position + Vector2.UP * SEGMENT_OFFSET
    var val = armoured
    armoured = false
    set_armoured(val)
    if hiding:
        talkable = false
    else:
        detection = $DetectionRange
    $GPUParticles2D.show()

func _process(delta):
    super._process(delta)
    if hiding:
        var body = $RayCast2D.get_collider()
        if body and body is Player:
            target = body
            no_ai = 1
            hiding = false
            do_detect()
            fall_time = 3
            detection = $DetectionRange
    if not child and segment_count > 0 and self.position.distance_to(spawn_point) > SEGMENT_OFFSET:
        var segment = segment_scene.instantiate()
        segment.position = get_segment_origin()
        segment.parent = self
        segment.segment_count = segment_count - 1
        segment.spawn_point = spawn_point
        segment.atk = self.atk
        segment.def = self.def * (0.5 if armoured else 1.0)
        add_sibling(segment)


        self.child = segment
    if child:
        child.update_material()
    if target and no_ai <= 0:
        if not $AudioStreamPlayer.playing:
            $AudioStreamPlayer.play()
        $AudioStreamPlayer.volume_linear = remap(
            clamp(Globals.game_manager.find_child("Player").position.distance_to(self.position), 0, 360), 
            0, 360, 0.8, 0
        )
    elif $AudioStreamPlayer.playing:
        await $AudioStreamPlayer.finished
        $AudioStreamPlayer.stop()
    $GPUParticles2D.emitting = $WallDetector.has_overlapping_bodies() and not hiding

func _physics_process(delta):
    var angle = PI * 0.5 if self.velocity == Vector2.ZERO else self.velocity.angle()
    var speed = self.velocity.length()
    fall_time -= delta
    if not hiding and no_ai <= 0 and not is_in_wall() and fall_time <= 0:
        if self.velocity.x != 0 and abs(self.velocity.x) < AERIAL_SPEED:
            self.velocity.x += ACCEL * delta * sign(self.velocity.x)
        self.velocity.y += GRAVITY * delta
        if abs(angle_difference(angle, self.velocity.angle())) > TURN_SPEED:
            self.velocity = Vector2.from_angle(clamp(self.velocity.angle(), angle - TURN_SPEED, angle + TURN_SPEED)) * self.velocity.length()
        if self.velocity.length() < SPEED_MIN:
            self.velocity = self.velocity.normalized() * SPEED_MIN
    elif target and no_ai <= 0 and not spare_time:
        if fall_time > 0 and self.velocity == Vector2.ZERO:
            speed = SPEED_MAX
            play_sound(switch_sfx)
            talkable = true
        var target_dir = target.position + Vector2.UP * 20 - self.position - target.get_position_delta() if target is Player else target - self.position
        var delta_angle = self.velocity.angle_to(target_dir)
        var turn_speed = TURN_SPEED * delta * remap(speed ** 2, 0, 200000, 1.5, 0.5)
        angle += clamp(delta_angle, - turn_speed, turn_speed)
        if speed < SPEED_MIN:
            speed += ACCEL * delta
        else:
            speed = clamp(speed + cos(delta_angle) * ACCEL * delta, SPEED_MIN, SPEED_MAX)
        self.velocity = Vector2.from_angle(angle) * speed
    else:
        self.velocity *= 1 - delta
    if self.velocity != Vector2.ZERO:
        $AnimatedSprite2D.rotation = angle - PI * 0.5
    move_and_slide()

func damage(player_atk, left = false, segment = false):
    if segment and armoured:
        self.def /= 2
    super.damage(player_atk, left)
    if segment and armoured:
        self.def *= 2
    if armoured and not segment and hp < max_hp * 0.75:
        set_armoured(false)

func do_death():
    if target is Vector2:
        return
    target = (target.position if target else self.position) + Vector2.from_angle(randf_range(0, 2 * PI)) * 1000
    detection = null
    await get_tree().create_timer(1).timeout
    while not is_in_wall(segment_count):
        await get_tree().create_timer(1).timeout
    super.do_death()

func do_spare():
    super.do_spare()
    target = (target.position if target else self.position) + Vector2.from_angle(randf_range(0, 2 * PI)) * 1000
    detection = null

func is_in_wall(min_count = 2):
    var count = 0
    if $VisibleOnScreenNotifier2D.is_on_screen() and not $WallDetector.has_overlapping_bodies():
        return false
    if child:
        count += child.segments_not_in_wall()
    return segment_count - count >= min_count

func set_armoured(val):
    if val and not armoured:
        $AnimatedSprite2D.play("hidden")
        $AnimatedSprite2D / Sprite2D.show()
        self.def *= 2
    elif not val and armoured:
        $AnimatedSprite2D.play("default")
        $AnimatedSprite2D / Sprite2D.hide()
        self.def /= 2
        play_sound(break_sfx)
        armour_broken = true
    armoured = val
