extends Level

var silhouette = preload("res://objects/silhouette.tres")
var heart_shard = preload("res://objects/heart_shard.tscn")

const intro_text = [
    "You want to leave so badly?", 
    "Hmph.", 
    "You are just like the others.", 
    "There is only one solution to this.", 
    "Prove yourself...", 
    "Prove to me that you are strong enough to survive!"
]

const extra_intro_text = [
    "...wait.", 
    "...why are you looking at me like that?", 
    "Like you have seen a ghost.", 
    "Do you know something that I do not?", 
    "No... That is impossible.", 
]

const flee_text = [
    "That is right.", 
    "Go upstairs."
]

const unflee_text = [
    "Already?", 
    "What will it take for you to learn your lesson?"
]

func _ready():
    $PointLight2D.show()
    if Globals.get_enemy_flag("toriel") != null:
        $CutsceneTrigger.hide()
        $Toriel.queue_free()
        $PointLight2D.queue_free()
        $Door.queue_free()
        $CameraLimitArea.hide()
    elif Globals.get_flag("toriel_home_prog", 0) < 4:
        $CutsceneTrigger.hide()
        $Toriel.queue_free()
        $PointLight2D.queue_free()
        $CameraLimitArea.hide()

func _on_cutscene_trigger_start_cutscene(player):
    $Toriel / Textbox.position.x = -25
    if Globals.get_flag("toriel_fleed"):
        await $Toriel / Textbox.show_text(unflee_text)
    else:
        await $Toriel / Textbox.show_text(intro_text)
        if Globals.get_persistent_flag("toriel_kill_count", 0) > 0:
            await $Toriel / Textbox.show_text(extra_intro_text)
    $Toriel / Textbox.position.x = 0
    await get_tree().create_timer(0.5).timeout
    get_tree().create_tween().tween_property($PointLight2D, "color", Color.WHITE, 2)
    $CutsceneTrigger2.show()
    $Toriel.start_fight()
    player.unpause()

func _on_cutscene_trigger2_start_cutscene(player):
    Globals.set_flag("toriel_fleed", true)
    $Toriel.abort_fight()
    get_tree().create_tween().tween_property($PointLight2D, "color", Color(0.2, 0.2, 0.2), 2)
    await get_tree().create_timer(0.5).timeout
    await $Textbox.show_text(flee_text)
    await get_tree().create_timer(0.5).timeout
    $CutsceneTrigger.show()
    player.unpause()

func _on_toriel_defeated(killed = false):
    if killed:
        Globals.set_persistent_flag("toriel_kill_count", Globals.get_persistent_flag("toriel_kill_count", 0) + 1)
    else:
        Globals.set_persistent_flag("toriel_spare_count", Globals.get_persistent_flag("toriel_spare_count", 0) + 1)
    await get_tree().create_timer(4 if killed else 1).timeout
    $Door.queue_free()
    $AudioStreamPlayer.play()
    $CutsceneTrigger2.hide()
    $CameraLimitArea.hide()
    get_tree().create_tween().tween_property($PointLight2D, "color", Color(0.2, 0.2, 0.2), 2)

func _on_toriel_death():
    var player: Player = Globals.game_manager.find_child("Player")
    player.pause()
    player.material = silhouette
    for node in self.get_children():
        if node is not DeathParticle and node is CanvasItem and node is not PointLight2D:
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
        if node is not DeathParticle and node is CanvasItem and node is not CutsceneTrigger:
            node.show()
    player.weapon = weapon
    get_tree().create_tween().tween_property($ColorRect, "modulate", Color.TRANSPARENT, 0.5)
    player.material = null
    player.unpause()
    _on_toriel_defeated(true)
