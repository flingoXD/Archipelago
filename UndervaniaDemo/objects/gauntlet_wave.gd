extends Node2D
class_name GauntletWave

var enemy_count = 0
var enemies = []
var player

signal count_changed(count)
signal defeated

func _ready():
    self.show()
    player = Globals.game_manager.find_child("Player")
    for node in get_children():
        if node is Enemy:
            enemy_count += 1
            enemies.append(node)
            remove_child(node)
            node.detection = null
            node.connect("death", _enemy_on_death(node))
            node.connect("spared", _enemy_on_spared(node))

func start_wave():
    if len(enemies) == 0:
        defeated.emit()
        return
    for node in enemies:
        node.no_ai = 1
        node.target = player
        add_child(node)
        if node.gauntlet_fade:
            fade_in(node)

func fade_in(enemy):
    enemy.modulate.a = 0
    enemy.talkable = false
    var tween = get_tree().create_tween()
    tween.tween_property(enemy, "modulate", Color.WHITE, 1)
    await tween.finished
    enemy.talkable = true

func enemy_defeated():
    enemy_count -= 1
    count_changed.emit(enemy_count)
    if enemy_count <= 0:
        defeated.emit()

func _enemy_on_death(_node):
    return func():
        enemy_defeated()

func _enemy_on_spared(_node):
    return func():
        enemy_defeated()
