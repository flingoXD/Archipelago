extends DamageHitbox

var impact_sfx = preload("res://sounds/impact.wav")

var _gravity = 300
var speed = 0

func _physics_process(delta):
    speed += _gravity * delta
    self.position.y += speed * delta

func _on_collided(body):
    if body is Boss:
        return
    var audio = AudioStreamPlayer.new()
    add_sibling(audio)
    audio.stream = impact_sfx
    audio.play()
    Globals.game_manager.camera_shake(5)
