extends Control
class_name HUD

@export var player: Player

var hidden_hud = false

signal quit

func _process(delta):
    if Input.is_action_just_pressed("hidden_hud"):
        hidden_hud = not hidden_hud
    if hidden_hud or Globals.get_flag("hidden_hud"):
        self.modulate.a = 0
    elif self.modulate.a < 1:
        self.modulate.a += delta
    if Input.is_action_pressed("quit"):
        if $TextureRect.modulate.a < 1:
            $TextureRect.modulate.a += delta * 0.3
            if $TextureRect.modulate.a >= 1:
                quit.emit()
    else:
        $TextureRect.modulate.a = 0
    $NameLabel.text = player.player_name + "\nLV " + str(player.lvl)
    $HPLabel.text = str(max(player.hp, 0)).pad_zeros(2) + "/" + str(player.max_hp).pad_zeros(2)
    $HPLabel / ProgressBar.max_value = player.max_hp
    $HPLabel / ProgressBar.value = player.hp
    $HPLabel / ProgressBar.scale.x = player.max_hp * 0.05
    $ActPopup.max_value = player.ACT_COOLDOWN
    $ActPopup.value = clamp(player.act_time, 0, player.ACT_COOLDOWN)
    $ActPopup / AnimatedSprite2D.visible = player.act_time > 0

func _on_player_hud_act(act):
    $ActPopup / AnimatedSprite2D.play(act)
