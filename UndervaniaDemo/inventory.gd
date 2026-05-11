extends Control

@warning_ignore("unused_signal")
signal inventory_exit

@export var player: Player

const LINE_LEN = 43

var selected_item
var selected_option
var stats_selected = false

func _ready():
    show()
    for node in self.get_children():
        node.hide()

func _process(_delta):
    if not $Menu.visible:
        return
    if Input.is_action_just_pressed("text_show"):
        if stats_selected:
            stats_selected = false
            $Stats.hide()
            $Menu / StatOption.select()
        elif $Menu / ItemOption / TextureRect.visible:
            $Menu / ItemOption / TextureRect.hide()
            $Menu / ItemOption / AudioStreamPlayer.play()
            inventory_exit.emit()
        elif $Menu / StatOption / TextureRect.visible:
            $Menu / StatOption / TextureRect.hide()
            $Menu / StatOption / AudioStreamPlayer.play()
            inventory_exit.emit()
        elif $ItemUse / UseOption / TextureRect.visible:
            $ItemUse / UseOption / TextureRect.hide()
            $ItemUse.hide()
            selected_option.select()
        elif $ItemUse / DropOption / TextureRect.visible:
            $ItemUse / DropOption / TextureRect.hide()
            $ItemUse.hide()
            selected_option.select()
    for node in $Items / VBoxContainer.get_children() + $Items / VBoxContainer2.get_children():
        if node.get_child(0).visible and selected_option != node:
            selected_option = node
            $ItemDesc / Label.text = get_display(node.item)

func get_display(item: Item):
    if not item:
        $ItemDesc.hide()
        return ""
    $ItemDesc.show()
    var stats = ""
    if item.display_stats:
        stats = " - " + item.display_stats
    elif item.edible:
        stats = " - Heals " + str(item.eat_hp) + " HP"
    elif item.wieldable:
        stats = " - +" + str(item.wield_atk) + " AT"
    elif item.wearable:
        stats = " - +" + str(item.wear_def) + " DF"
    var desc = item.description






    return item.display_name + stats + "\n" + desc

func show_inventory():
    $Menu.show()
    $Menu / ItemOption.select()
    var inv_size = len(player.inventory)
    var display_size = $Items / VBoxContainer.get_child_count() + $Items / VBoxContainer2.get_child_count()
    for i in range(min(inv_size, display_size)):
        if i < 4:
            $Items / VBoxContainer.get_child(i).item = player.inventory[i]
        else:
            $Items / VBoxContainer2.get_child(i - 4).item = player.inventory[i]
    if display_size > inv_size:
        for i in range(inv_size, display_size):
            if i < 4:
                $Items / VBoxContainer.get_child(i).item = null
            else:
                $Items / VBoxContainer2.get_child(i - 4).item = null
    $Stats / NameLabel.text = player.player_name
    $Stats / LevelLabel.text = "LV " + str(player.lvl)
    $Stats / HpLabel.text = "HP " + str(player.hp) + "/" + str(player.max_hp)
    $Stats / AtkLabel.text = "AT " + str(player.atk - 10) + " (" + str(player.atk_mod) + ")"
    $Stats / DefLabel.text = "DF " + str(player.def - 10) + " (" + str(player.def_mod) + ")"
    $Stats / ExpLabel.text = "EXP: " + str(player.xp)
    $Stats / GoldLabel.text = "GOLD: " + str(player.gold)
    var abilities = []
    for move in Globals.moves:
        if Globals.has_ability(move):
            abilities.append(move.capitalize())
    $Stats / AbilityLabel.text = "Abilities: " + ", ".join(abilities) if len(abilities) > 0 else "No abilities"
    var acts = []
    for act in Globals.acts:
        if Globals.has_ability(act) and not Globals.input_keys[act].begins_with("act"):
            acts.append(act.capitalize())
    $Stats / ActLabel.text = "ACTs: " + ", ".join(acts) if len(acts) > 0 else "No special acts"
    $Stats / VBoxContainer / Act1Label.text = "ACT 1: " + ("Cheer" if Globals.has_ability("cheer") else "...")
    $Stats / VBoxContainer / Act2Label.text = "ACT 2: " + ("Threat" if Globals.has_ability("threat") else "...")
    $Stats / VBoxContainer2 / WeaponLabel.text = "WPN: " + (player.weapon.get_nickname() if player.weapon else "...")
    $Stats / VBoxContainer2 / ArmorLabel.text = "ARM: " + (player.armour.get_nickname() if player.armour else "...")

func _on_item_option_selected():
    $Menu / ItemOption / TextureRect.hide()
    $Items.show()
    await get_tree().create_timer(0.01).timeout
    $Items / VBoxContainer / InventoryOption.select()

func _on_items_selected(item):
    if not item:
        $Items.hide()
        $ItemDesc.hide()
        $Menu / ItemOption.select()
        selected_option = null
        return
    selected_item = item
    $ItemUse.show()
    await get_tree().create_timer(0.01).timeout
    $ItemUse / UseOption.select()

func _on_use_option_selected():
    $ItemUse / UseOption / TextureRect.hide()
    @warning_ignore("redundant_await")
    if selected_item and await selected_item.on_use(player):
        player.inventory.pop_at(player.inventory.find(selected_item))
    inventory_exit.emit()

func _on_drop_option_selected():
    $ItemUse / DropOption / TextureRect.hide()
    @warning_ignore("redundant_await")
    if selected_item and await selected_item.on_drop(player):
        player.inventory.pop_at(player.inventory.find(selected_item))
    inventory_exit.emit()

func _on_inventory_exit():
    for node in self.get_children():
        node.hide()

func _on_stat_option_selected():
    $Menu / StatOption / TextureRect.hide()
    $Stats.show()
    stats_selected = true
