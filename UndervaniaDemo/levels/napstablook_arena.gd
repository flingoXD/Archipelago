extends Level

var boss_fight = 0

const text = [
    [
        "i usually come to the RUINS because there's nobody around...", 
        "but today i met somebody nice...", 
        "...", 
        "oh, i'm rambling again", 
        "i'll get out of your way", 
    ], 
    [
        "oh no... i forgot you can't just walk through the door", 
        "i'd better let you through"
    ]
]

func get_stream():
    if Globals.get_enemy_flag("napstablook") != null or Globals.get_flag("genocide"):
        return stream
    return null

func _ready():
    if Globals.get_enemy_flag("napstablook") != null or Globals.get_flag("genocide"):
        $NapstablookNPC.hide()
        $CameraLimitArea.queue_free()
        boss_fight = 2
    if Globals.get_flag("door_napstablook_arena"):
        $Lever.active = true
        $Door.hide()
        $Door / CollisionShape2D.set_deferred("disabled", true)

func _process(_delta):
    if boss_fight == 0:
        for area in $NapstablookNPC / Area2D.get_overlapping_areas():
            if area.visible and area.get_parent() is Player:
                boss_fight = 1
                $NapstablookNPC.talkable = false

                var tween = get_tree().create_tween()
                tween.tween_property($NapstablookNPC, "modulate", Color.TRANSPARENT, 1)
                await tween.finished
                $NapstablookNPC.hide()
                $Napstablook.start_fight()
    if $Lever.active and $Door.visible:
        $Door.hide()
        $Door / CollisionShape2D.set_deferred("disabled", true)
        Globals.set_flag("door_napstablook_arena", true)

func _on_napstablook_spared():
    boss_fight = 2
    await get_tree().create_timer(1).timeout
    var player = get_parent().find_child("Player")
    player.pause()
    var tween = get_tree().create_tween()
    tween.tween_property($FakeNapstablookNPC, "modulate", Color.WHITE, 1)
    await tween.finished
    await $FakeNapstablookNPC / Textbox.show_text(text[0])
    if not Globals.get_flag("door_napstablook_arena"):
        $FakeNapstablookNPC.flip_h = true
        tween = get_tree().create_tween()
        tween.tween_property($FakeNapstablookNPC, "position", Vector2(340, 200), 1)
        await tween.finished
        await get_tree().create_timer(0.5).timeout
        $FakeNapstablookNPC / Textbox.position.x -= 60
        await $FakeNapstablookNPC / Textbox.show_text(text[1])
        await get_tree().create_timer(0.5).timeout
        $Lever.active = true
        $Lever / AudioStreamPlayer.play()
    $CameraLimitArea.queue_free()
    await get_tree().create_timer(0.5).timeout
    player.unpause()
    get_parent().play_stream(stream)
    tween = get_tree().create_tween()
    tween.tween_property($FakeNapstablookNPC, "modulate", Color.TRANSPARENT, 1)
    await tween.finished
    $FakeNapstablookNPC.hide()
