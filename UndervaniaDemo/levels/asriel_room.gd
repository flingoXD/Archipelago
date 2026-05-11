extends Level

var asgore_talk = preload("res://sounds/asgore_talk.wav")

var facing_lamp = false
var lamp_on
var player: Player

func _ready():
    player = Globals.game_manager.find_child("Player")
    lamp_on = Globals.get_flag("asrielroom_lamp", true)
    if not lamp_on:
        update_lamp()
    if not Globals.get_flag("toriel_bed"):
        $ItemCollect.hide()

func _process(_delta):
    if $Bed.visible and player in $Bed.get_overlapping_bodies() and player.look == "up":
        do_sleep()
    if player in $Lamp.get_overlapping_bodies() and player.look == "up":
        if not facing_lamp:
            lamp_on = not lamp_on
            $Lamp / AudioStreamPlayer.play()
            facing_lamp = true
            update_lamp()
        return
    facing_lamp = false
    if $Hallway2.visible and player.position.x < 225:
        $Hallway2.hide()

func update_lamp():
    Globals.set_flag("asrielroom_lamp", lamp_on)
    self.stream.stream_mask = 2 if lamp_on else 8
    Globals.game_manager.play_stream(self.stream)
    self.light_override = 1.0 if lamp_on else 0.1
    player.light_override = self.light_override
    Globals.game_manager.find_child("CanvasModulate").color.v = 0.1 + 0.1 * self.light_override

func do_sleep():
    $Bed.hide()
    Globals.game_manager.level_transition(null, player.position, InteractDoor.LOOK.DOWN)
    while player.look == "up":
        await get_tree().create_timer(0.01).timeout
    $Bed.show()
    $ColorRect2.show()
    $ColorRect2.modulate = Color.WHITE
    player.pause()
    Globals.game_manager.play_stream()
    Globals.set_flag("hidden_hud", true)
    $Hallway2.show()
    player.hp = max(player.hp, player.max_hp)
    var prog = Globals.get_flag("toriel_home_prog", 0)
    if prog < 7:
        await get_tree().create_timer(3).timeout
        if prog < 4:
            lamp_on = false
            update_lamp()
            Globals.set_flag("toriel_bed", true)
            if not Globals.get_flag("pie_collect"):
                $ItemCollect.show()
    else:
        $ColorRect2 / Textbox.set_talk_sound(asgore_talk)
        await get_tree().create_timer(1).timeout
        await $ColorRect2 / Textbox.show_text([
            player.player_name + ", please...", 
            "Wake up!", 
            "You are the future of humans and monsters!"
        ])
        await get_tree().create_timer(1).timeout
    Globals.game_manager.play_stream(self.stream)
    Globals.set_flag("hidden_hud", false)
    var tween = get_tree().create_tween()
    tween.tween_property($ColorRect2, "modulate", Color.TRANSPARENT, 0.5)
    await tween.finished
    player.unpause()
