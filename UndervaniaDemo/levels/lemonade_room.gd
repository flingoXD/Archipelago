extends Level

var text = [
    [
        "It's a lemonade stand. There's only enough left for one glass.", 
        "The sign says, 'Free for all - please leave a tip!'", 
        "You pour out a glass of lemonade. (Press [" + Globals.get_key_name("heal") + "] to quickly use an item.)"
    ], 
    "You don't have any gold to leave a tip!", 
    "You leave 5G as a tip for the lemonade.", 
    "You only leave 1G as a tip for the lemonade, since you don't have 5G.", 
    "There isn't any more lemonade left, sadly.", 
    "You're carrying too many items."
]

@export var item: Item
var lemonade_taken = false
var lemonade_tip = false
var showing = false

func _ready():
    lemonade_taken = Globals.get_flag("lemonade_collect")
    lemonade_tip = Globals.get_flag("lemonade_tip")

func _process(_delta):
    for body in $LemonadeStand / Area2D.get_overlapping_bodies():
        if body is Player:
            if body.look == "up" and not body.flip_h and not showing:
                showing = true
                body.pause()
                if lemonade_tip:
                    await body.find_child("Textbox").show_text(text[4])
                elif lemonade_taken:
                    if body.spend_gold(5):
                        await body.find_child("Textbox").show_text(text[2])
                        lemonade_tip = true
                    elif body.spend_gold(1):
                        await body.find_child("Textbox").show_text(text[3])
                        lemonade_tip = true
                    else:
                        await body.find_child("Textbox").show_text(text[1])
                    Globals.set_flag("lemonade_tip", lemonade_tip)
                elif Globals.game_manager.ap_check_location(item.item_id):
                    await body.find_child("Textbox").show_text(text[0])
                else:
                    await body.find_child("Textbox").show_text(text[5])
                await get_tree().create_timer(0.5).timeout
                body.unpause()
            elif body.look != "up" and showing:
                showing = false
