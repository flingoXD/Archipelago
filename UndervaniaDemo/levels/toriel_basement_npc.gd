extends AnimatedSprite2D

var toriel_talk = preload("res://sounds/toriel_talk.wav")

@export var toriel_home_prog = 0
@export var dialogue: Array[String]

var hd_remaster = Globals.get_persistent_flag("silly_shader") == "hd_remaster"

func _ready():
    $Textbox.set_talk_sound(toriel_talk)
    var actual_prog = Globals.get_flag("toriel_home_prog")
    if actual_prog >= toriel_home_prog or actual_prog < 4:
        self.hide()
        $CutsceneTrigger.hide()
    if hd_remaster:
        self.play("hd_remaster")
        self.scale = Vector2(0.5, 0.5)
        $Textbox.position *= 2
        $Textbox.scale *= 2

func _on_cutscene_trigger_start_cutscene(player):
    await $Textbox.show_text(dialogue)
    if not hd_remaster:
        self.play("walk")
    var tween = get_tree().create_tween()
    tween.tween_property(self, "position", self.position + Vector2.RIGHT * 160, 2)
    await tween.finished
    self.hide()
    Globals.set_flag("toriel_home_prog", toriel_home_prog)
    player.unpause()
