extends RigidBody2D

var this_scene = load("res://bullets/moldsmal_attack.tscn")

@export var big_material: PhysicsMaterial
@export var small_material: PhysicsMaterial
@export var big_texture: Texture2D
@export var small_texture: Texture2D

var atk = 0
var big = false:
    set(val):
        big = val
        if big:
            self.physics_material_override = big_material
            $Sprite2D.texture = big_texture
        else:
            self.physics_material_override = small_material
            $Sprite2D.texture = small_texture

func _on_body_entered(body):
    if body is Player:
        body.damage(atk, body.global_position.x < self.global_position.x)
        self.queue_free()
    elif not big:
        self.queue_free()

func _on_timer_timeout():
    if not big:
        return
    var parent = self.get_parent()
    for i in range(9):
        var new = this_scene.instantiate()
        var rot = i * 2 * PI / 9
        new.linear_velocity = Vector2(cos(rot), sin(rot)) * 160
        new.big = false
        new.atk = self.atk
        parent.add_child(new)
        new.position = self.position
    self.queue_free()
