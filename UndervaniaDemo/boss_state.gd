extends Resource
class_name BossState

var boss: Boss
var lifetime = 10
var successors = []
var predecessor

func start():
    pass

func end():
    pass

func process(delta):
    lifetime -= delta
    if lifetime <= 0:
        boss.boss_state = successors[randi() % len(successors)].new()

func physics_process(_delta):
    pass

func remove_predecessor():
    for i in range(len(successors)):
        if is_instance_of(predecessor, successors[i]):
            successors.remove_at(i)
            return
