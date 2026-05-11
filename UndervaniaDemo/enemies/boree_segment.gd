extends Enemy

var segment_scene = preload("res://enemies/boree_segment.tscn")

const SEGMENT_OFFSET = 7

var segment_count = 0
var dir = Vector2.DOWN
var parent
var child
var spawn_point

func get_segment_origin():
    return self.position - dir * SEGMENT_OFFSET

func _ready():
    super._ready()
    talkable = false
    if segment_count > 0:
        $TailSprite.hide()
    else:
        $BodySprite.hide()
    $GPUParticles2D.show()

func _process(delta):
    super._process(delta)
    if not child and segment_count > 0 and self.position.distance_to(spawn_point) > SEGMENT_OFFSET:
        var segment = segment_scene.instantiate()
        segment.position = get_segment_origin()
        segment.parent = self
        segment.segment_count = segment_count - 1
        segment.spawn_point = spawn_point
        segment.atk = self.atk
        add_sibling(segment)


        segment_count = 0
        self.child = segment
    $GPUParticles2D.emitting = $WallDetector.has_overlapping_bodies()

func _physics_process(_delta):
    if not parent:
        queue_free()
        return

    var old_end = get_segment_origin()
    self.position = parent.get_segment_origin()
    dir = - self.position.direction_to(old_end)
    self.rotation = dir.angle() - PI * 0.5

func damage(player_atk, left = false, _segment = false):
    parent.damage(player_atk, left, true)

func update_material():
    self.material = parent.material
    if child:
        child.update_material()

func segments_not_in_wall():
    var count = 0
    if $VisibleOnScreenNotifier2D.is_on_screen() and not $WallDetector.has_overlapping_bodies():
        count += 1
    if child:
        count += child.segments_not_in_wall()
    return count
