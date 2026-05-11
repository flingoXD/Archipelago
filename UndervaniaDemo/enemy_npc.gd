extends NPC
class_name EnemyNPC

@export var enemy_id: String
@export var talk1: Array[String]
@export var talk_end: Array[String]
@export var cheer: Array[String]

var talk_count = 1

func _ready():
    if enemy_id and Globals.get_enemy_flag(enemy_id) != false or Globals.get_flag("genocide"):
        self.queue_free()
    for a in [talk1, talk_end, cheer]:
        for i in range(len(a)):
            a[i] = a[i].replace("\\n", "\n")

func talk(act):
    if act == "cheer" and cheer:
        await $Textbox.show_text(cheer)
    else:
        await $Textbox.show_text(talk1 if talk_count == 1 else talk_end)
        talk_count += 1
