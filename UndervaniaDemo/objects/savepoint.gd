extends AnimatedSprite2D

var cooldown = 0

func _ready():
    self.play("default")

func _process(delta):
    cooldown -= delta
    for area in $Area2D.get_overlapping_areas():
        if area.visible and area.get_parent() is Player and cooldown <= 0:
            Globals.save_game(get_parent())
            var player = area.get_parent()
            player.hp = player.max_hp
            $AudioStreamPlayer.play()
            cooldown = 1
            var kills = Globals.get_flag("kills")
            if kills >= Globals.kill_total - 20 and Globals.get_flag("genocide") == null:
                player.pause()
                await player.find_child("Textbox").show_text("[color=red]" + str(round(Globals.kill_total - kills)) + " left.[/color]")
                await get_tree().create_timer(0.5).timeout
                player.unpause()
