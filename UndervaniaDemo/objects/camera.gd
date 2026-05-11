extends Camera2D

const LOOK_OFFSET = 20
const FREECAM_SPEED = 100

var paused = false
var freecam = false
var shake = 0
var look_dir = Vector2.ZERO:
    set(val):
        if val != look_dir:
            look_time = 0
        look_dir = val
var look_time = 0

@export var level: Level:
    set(val):
        level = val
        self.limit_enabled = val is Level
        if self.limit_enabled:
            self.limit_left = val.limit_left
            self.limit_right = val.limit_right
            self.limit_top = val.limit_top
            self.limit_bottom = val.limit_bottom
            reset_smoothing()

func set_pos(pos):
    self.position = pos
    $Area2D.position = Vector2( - pos.x, - pos.y)

func _process(delta):
    look_dir = get_parent().look_dir
    look_time += delta
    if freecam and not paused:
        set_pos(self.position + Input.get_vector("left", "right", "up", "down") * FREECAM_SPEED * delta)
    elif position_smoothing_enabled and (look_time > 0.5 or look_dir.y == 0):
        set_pos(look_dir * LOOK_OFFSET)
    else:
        set_pos(Vector2.ZERO)
    if shake:
        self.offset = Vector2(randf_range( - shake, shake), randf_range( - shake, shake))
        shake = max(shake - delta * 10, 0)
    else:
        self.offset = Vector2.ZERO
    for area in $Area2D.get_overlapping_areas():
        if area is CameraLimitArea and area.visible and self.limit_enabled:
            self.limit_left = area.limit_left if area.limit_left != null else level.limit_left
            self.limit_right = area.limit_right if area.limit_right != null else level.limit_right
            self.limit_top = area.limit_top if area.limit_top != null else level.limit_top
            self.limit_bottom = area.limit_bottom if area.limit_bottom != null else level.limit_bottom
            return
    if level and not paused:
        self.limit_left = level.limit_left
        self.limit_right = level.limit_right
        self.limit_top = level.limit_top
        self.limit_bottom = level.limit_bottom
