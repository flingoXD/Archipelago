extends Node2D

const MARGIN = 16
const WIDTH = 640 - MARGIN * 2
const HEIGHT = 480 - MARGIN * 2
const SPEED = 200
const ACCEL = 2000
const POS_RATIO = 0.1
const TILE_SIZE = 4

@export var player: Player

var current_room
var current_map_room
var velocity = Vector2.ZERO

func _ready():
    update()
    for node: AnimatedSprite2D in self.find_children("*", "AnimatedSprite2D"):
        node.play()

func update():
    var rect = null
    for node: MapRoom in self.find_children("*", "MapRoom"):
        node.visible = Globals.game_manager and Globals.game_manager.godmode or Globals.has_room(node.room)\
and ( not node.require_flag or Globals.get_flag(node.require_flag) == node.require_flag_val)\
and ( not node.exclude_flag or Globals.get_flag(node.exclude_flag) != node.exclude_flag_val)
        if node.visible:
            if rect:
                rect = rect.merge(node.rect if node.rect else node.get_used_rect())
            else:
                rect = node.rect if node.rect else node.get_used_rect()
    if not rect:
        return
    rect.position *= TILE_SIZE
    rect.size *= TILE_SIZE
    if rect.size.x < WIDTH:
        rect.position.x -= (WIDTH - rect.size.x) * 0.5
        rect.size.x = WIDTH
    if rect.size.y < HEIGHT:
        rect.position.y -= (HEIGHT - rect.size.y) * 0.5
        rect.size.y = HEIGHT
    $Camera2D.limit_left = rect.position.x - MARGIN
    $Camera2D.limit_right = rect.end.x + MARGIN
    $Camera2D.limit_top = rect.position.y - MARGIN
    $Camera2D.limit_bottom = rect.end.y + MARGIN
    if current_room:
        $Heart.position = find_player_pos()

func find_center(room = null):
    var rect = null
    for node: MapRoom in self.find_children("*", "MapRoom"):
        if node.visible and ( not room or node.room == room):
            if rect:
                rect = rect.merge(node.rect if node.rect else node.get_used_rect())
            else:
                rect = node.rect if node.rect else node.get_used_rect()
    if rect:
        return (rect.position + rect.end) * 2
    return $Heart.position

func move_to_center(room = null):
    if not room:
        room = current_room
    update()
    var center = find_center(room)
    current_room = room
    $Heart.position = center
    $Camera2D.position = round(center)
    $Camera2D.reset_smoothing()

func find_player_pos():
    if not current_map_room or current_map_room.room != current_room:
        for node in self.get_children():
            if node is MapRoom and node.visible and node.room == current_room:
                current_map_room = node
                break
    if not current_map_room or current_map_room.origin == Vector2.ZERO:
        return find_center(current_room)
    var pos = player.position * POS_RATIO
    if current_map_room == $StrytaxArena and pos.y < -24 * TILE_SIZE:
        pos = Vector2(4, -24) * TILE_SIZE
    elif current_map_room == $LongCorridor and Globals.game_manager.level:
        pos.x -= Globals.game_manager.level.position.x * POS_RATIO
    return pos + current_map_room.origin * TILE_SIZE

func handle_inputs(delta):
    var accel = Input.get_vector("left", "right", "up", "down")
    if accel.x != 0:
        velocity.x = clamp(velocity.x + accel.x * ACCEL * delta, - SPEED, SPEED)
    else:
        velocity.x = 0 if abs(velocity.x) < ACCEL * delta else velocity.x - ACCEL * delta * sign(velocity.x)
    if accel.y != 0:
        velocity.y = clamp(velocity.y + accel.y * ACCEL * delta, - SPEED, SPEED)
    else:
        velocity.y = 0 if abs(velocity.y) < ACCEL * delta else velocity.y - ACCEL * delta * sign(velocity.y)
    $Camera2D.position += velocity * delta
    $Camera2D.global_position = round(clamp(
        $Camera2D.global_position, 
        Vector2($Camera2D.limit_left + WIDTH * 0.5, $Camera2D.limit_top + HEIGHT * 0.5), 
        Vector2($Camera2D.limit_right - WIDTH * 0.5, $Camera2D.limit_bottom - HEIGHT * 0.5)
    ))
