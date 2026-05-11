extends Level

@export var doughnut: Item
@export var cider: Item
var showing = false

func _process(_delta):
    check_interaction($SmallWeb / Area2D, 7, doughnut)
    check_interaction($BigWeb / Area2D, 18, cider)

func check_interaction(area, cost, item):
    for body in area.get_overlapping_bodies():
        if body and body is Player:
            if body.look == "up" and not showing:
                showing = true
                body.pause()
                if body.gold < cost:
                    await body.find_child("Textbox").show_text("You don't have enough gold for that!")
                elif Globals.game_manager.ap_check_location(item.duplicate().item_id):
                    body.spend_gold(cost)
                    await body.find_child("Textbox").show_text([
                        "You left " + str(cost) + "G in the web.", 
                        "Some spiders crawled down and gave you a " + ("donut" if item == doughnut else "jug") + "."
                    ])
                else:
                    await body.find_child("Textbox").show_text("You're carrying too many items.")
                await get_tree().create_timer(0.5).timeout
                body.unpause()
            elif body.look != "up" and showing:
                showing = false
