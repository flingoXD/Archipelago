extends NinePatchRect

@export var player: Player

signal selected(item)

func _ready():
    hide()

func pick_item():
    var inv_size = len(player.inventory)
    var display_size = $VBoxContainer.get_child_count()
    for i in range(min(inv_size, display_size)):
        $VBoxContainer.get_child(i).item = player.inventory[i]
    if display_size > inv_size:
        for i in range(inv_size, display_size):
            $VBoxContainer.get_child(i).item = null
    $VBoxContainer / InventoryOption.select()
    show()
    var item = await selected
    hide()
    return item
