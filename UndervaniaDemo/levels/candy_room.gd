extends Level

var text = [
    [
        "It's a bowl of candy. There's a label saying 'take one'.", 
        "You take a piece of candy. (Press [" + Globals.get_key_name("heal") + "] to quickly use an item.)"
    ], 
    "You take more candy. How disgusting...", 
    "You take another piece. You feel like the scum of the earth...", 
    "You took too much too fast. The candy has spilled onto the floor.", 
    "Look at what you've done.", 
    "You try to take a piece of candy, but you don't have any room."
]

@export var item: Item
var candy_count = 0
var showing = false

func _ready():
    candy_count = Globals.get_flag("monster_candy_collect", 0)
    if candy_count >= 4:
        $CandyStand / Sprite2D.hide()
    else:
        $CandyStand / Sprite2D2.hide()

func _process(_delta):
    for body in $CandyStand.get_overlapping_bodies():
        if body is Player:
            if body.look == "up" and not body.flip_h and not showing:
                showing = true
                body.pause()
                if candy_count >= 4:
                    await body.find_child("Textbox").show_text(text[4])
                elif Globals.game_manager.ap_check_location(item.duplicate().item_id):
                    await body.find_child("Textbox").show_text(text[candy_count])
                    candy_count += 1
                    Globals.set_flag("monster_candy_collect", candy_count)
                    if candy_count >= 4:
                        $CandyStand / Sprite2D.hide()
                        $CandyStand / Sprite2D2.show()
                else:
                    await body.find_child("Textbox").show_text(text[5])
                await get_tree().create_timer(0.5).timeout
                body.unpause()
            elif body.look != "up" and showing:
                showing = false
