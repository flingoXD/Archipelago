extends DamageHitbox

var impact_sfx = preload("res://sounds/rorrim_attack.wav")
var shard_scene = preload("res://bullets/rorrim_attack_shard.tscn")

var _gravity = 300
var speed = 0

func _physics_process(delta):
    speed += _gravity * delta
    self.position.y += speed * delta

func _on_collided(body):
    if body is Enemy:
        return
    var audio = AudioStreamPlayer.new()
    add_sibling(audio)
    audio.stream = impact_sfx
    audio.play()
    for i in range(randi_range(2, 3)):
        var shard = shard_scene.instantiate()
        add_sibling(shard)
        shard.position = self.position
