from __future__ import annotations

from typing import TYPE_CHECKING

from BaseClasses import Item, ItemClassification

if TYPE_CHECKING:
    from .world import UVDemoWorld

ITEM_NAME_TO_ID = {
    "Bandage": 1,
    "Candy Corn": 2,
    "Corn Dog": 3,
    "Strytax's Sword": 4,
    "Faded Ribbon": 5,
    "Golden Pear": 6,
    "Lemonade": 7,
    "Monster Candy": 8,
    "Raffle Ticket": 9,
    "Pie": 10,
    "Rock Candy": 11,
    "Shadow Amulet": 12,
    "Spider Cider": 13,
    "Spider Donut": 14,
    "Stick": 15,
    "Toy Knife": 16,
    "Crispy Scroll": 17,
    "Act - Talk": 18,
    "Act - Cheer": 19,
    "Act - Threat": 20,
    "Act - Check": 21,
    "Glide": 22,
    "10 Gold": 23,
    "Lantern": 24,
}

DEFAULT_ITEM_CLASSIFICATIONS = {
    "Bandage": ItemClassification.useful,
    "Candy Corn": ItemClassification.useful,
    "Corn Dog": ItemClassification.useful,
    "Strytax's Sword": ItemClassification.progression,
    "Faded Ribbon": ItemClassification.useful,
    "Golden Pear": ItemClassification.useful,
    "Lemonade": ItemClassification.useful,
    "Monster Candy": ItemClassification.useful,
    "Raffle Ticket": ItemClassification.progression,
    "Pie": ItemClassification.useful,
    "Rock Candy": ItemClassification.filler,
    "Shadow Amulet": ItemClassification.useful,
    "Spider Cider": ItemClassification.useful,
    "Spider Donut": ItemClassification.useful,
    "Stick": ItemClassification.progression,
    "Toy Knife": ItemClassification.progression,
    "Crispy Scroll": ItemClassification.trap,
    "Act - Talk": ItemClassification.progression,
    "Act - Cheer": ItemClassification.progression,
    "Act - Threat": ItemClassification.progression,
    "Act - Check": ItemClassification.useful,
    "Glide": ItemClassification.progression,
    "10 Gold": ItemClassification.filler,
    "Lantern": ItemClassification.useful,
}

class UVDemoItem(Item):
    game = "Undervania Demo"

def get_random_filler_item_name(world: UVDemoWorld) -> str:
    return "Rock Candy"


def create_item_with_correct_classification(world: UVDemoWorld, name: str) -> UVDemoItem:
    classification = DEFAULT_ITEM_CLASSIFICATIONS[name]
    return UVDemoItem(name, classification, ITEM_NAME_TO_ID[name], world.player)

def create_all_items(world: UVDemoWorld) -> None:
    itempool: list[Item] = [
        world.create_item("Bandage"),
        world.create_item("Candy Corn"),
        world.create_item("Corn Dog"),
        world.create_item("Strytax's Sword"),
        world.create_item("Faded Ribbon"),
        world.create_item("Golden Pear"),
        world.create_item("Lemonade"),
        world.create_item("Monster Candy"),
        world.create_item("Raffle Ticket"),
        world.create_item("Pie"),
        world.create_item("Rock Candy"),
        world.create_item("Shadow Amulet"),
        world.create_item("Stick"),
        world.create_item("Toy Knife"),
        world.create_item("Crispy Scroll"),
        world.create_item("Act - Talk"),
        world.create_item("Act - Cheer"),
        world.create_item("Act - Threat"),
        world.create_item("Act - Check"),
        world.create_item("Glide"),
        world.create_item("Lantern"),
    ]
    for _ in range(2):
        itempool.append(world.create_item("Spider Cider"))
        itempool.append(world.create_item("Spider Donut"))
    for _ in range(3): itempool.append(world.create_item("10 Gold"))

    number_of_items = len(itempool)
    number_of_unfilled_locations = len(world.multiworld.get_unfilled_locations(world.player))
    needed_number_of_filler_items = number_of_unfilled_locations - number_of_items
    
    itempool += [world.create_filler() for _ in range(needed_number_of_filler_items)]
    world.multiworld.itempool += itempool
