extends Level

var godhome = load("res://levels/godhome.tscn")
var silhouette = preload("res://objects/silhouette.tres")
var heart_shard = preload("res://objects/heart_shard.tscn")

func _ready():
    $Toriel.start_fight.call_deferred()

func exit():
    await get_tree().create_timer(2).timeout
    Globals.game_manager.level_transition(godhome, Vector2(30, 107.5), 0)

func _on_toriel_death():
    var player: Player = Globals.game_manager.find_child("Player")
    player.pause()
    player.material = silhouette
    for node in self.get_children():
        if node is not DeathParticle and node is CanvasItem:
            node.hide()
    var weapon = player.weapon
    player.weapon = null
    $Soul.show()
    var tween = get_tree().create_tween()
    tween.tween_property($Soul, "position", $Soul.position + Vector2.UP * 50, 5)
    await tween.finished
    $Soul.texture.region.position.x = 20
    $Soul / AudioBreak1.play()
    await get_tree().create_timer(1.5).timeout
    $Soul.hide()
    $Soul / AudioBreak2.play()
    for i in range(6):
        var shard = heart_shard.instantiate()
        self.add_child(shard)
        shard.linear_velocity = 200 * Vector2.from_angle(randf_range(0, 2 * PI))
        shard.position = $Soul.position
        shard.material = silhouette
    await get_tree().create_timer(5).timeout
    $Soul.queue_free()
    for node in self.get_children():
        if node is not DeathParticle and node is CanvasItem:
            node.show()
    player.weapon = weapon
    get_tree().create_tween().tween_property($ColorRect, "modulate", Color.TRANSPARENT, 0.5)
    player.material = null
    player.unpause()
    exit()
