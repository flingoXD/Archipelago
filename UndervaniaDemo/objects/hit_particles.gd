extends GPUParticles2D

func _ready():
    emitting = true
    await finished
    queue_free()

func _physics_process(_delta):
    speed_scale = 1 / Engine.time_scale
