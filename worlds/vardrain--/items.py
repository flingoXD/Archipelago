from __future__ import annotations

from typing import TYPE_CHECKING

from BaseClasses import Item, ItemClassification

if TYPE_CHECKING:
    from .world import VardrainWorld

# Make Vertical Scale Blocks given at the start, as Tutorial and HELLevator!! are possible with just that
ITEM_NAME_TO_ID = {
    "Vertical Scale Blocks": 1,
    "Push Platforms": 2,
    "Fragile Blocks": 3,
    "Anvils": 4,
    "Ropes": 5,
    "Push Blocks": 6,
    "Deactivateable Platforms": 7,
    "Pull Blocks": 8,
    "Place Indicators": 9,
    "Cannons": 10,
    "Enemy Life": 11,
    "Square Enemy Gravity": 12,
    "Sway Platforms": 13,
    "Moveable Platforms": 14,
    "KillRope Thickness": 15,
    "Spawn Enemy": 16,
    "Bombs": 17,
    "Chains Door": 18
}

DEFAULT_ITEM_CLASSIFICATIONS = {
    "Vertical Scale Blocks": ItemClassification.progression,
    "Push Platforms": ItemClassification.progression,
    "Fragile Blocks": ItemClassification.progression,
    "Ropes": ItemClassification.progression,
    "Push Blocks": ItemClassification.progression,
    "Deactivateable Platforms": ItemClassification.progression,
    "Pull Blocks": ItemClassification.progression,
    "Place Indicators": ItemClassification.progression,
    "Cannons": ItemClassification.progression,
    "Enemy Life": ItemClassification.progression,
    "Square Enemy Gravity": ItemClassification.progression,
    "Sway Platforms": ItemClassification.useful,
    "Moveable Platforms": ItemClassification.progression,
    "KillRope Thickness": ItemClassification.progression,
    "Spawn Enemy": ItemClassification.trap,
    "Bombs": ItemClassification.progression,
    "Chains Door": ItemClassification.progression
}

class VardrainItem(Item):
    game = "vardrain--"

def get_random_filler_item_name(world: VardrainWorld) -> str:
    return "Spawn Enemy"

def create_item_with_correct_classification(world: VardrainWorld, name: str) -> VardrainItem:
    classification = DEFAULT_ITEM_CLASSIFICATIONS[name]
    return VardrainItem(name, classification, ITEM_NAME_TO_ID[name], world.player)

def create_all_items(world: VardrainWorld) -> None:
    itempool: list[Item] = [
        world.create_item("Push Platforms"),
        world.create_item("Fragile Blocks"),
        world.create_item("Ropes"),
        world.create_item("Push Blocks"),
        world.create_item("Deactivateable Platforms"),
        world.create_item("Pull Blocks"),
        world.create_item("Cannons"),
        world.create_item("Enemy Life"),
        world.create_item("Square Enemy Gravity"),
        world.create_item("Sway Platforms"),
        world.create_item("Moveable Platforms"),
        world.create_item("KillRope Thickness"),
        world.create_item("Bombs"),
    ]

    number_of_items = len(itempool)
    number_of_unfilled_locations = len(world.multiworld.get_unfilled_locations(world.player))
    needed_number_of_filler_items = number_of_unfilled_locations - number_of_items
    
    itempool += [world.create_filler() for _ in range(needed_number_of_filler_items)]
    world.multiworld.itempool += itempool

    world.push_precollected(world.create_item("Vertical Scale Blocks"))
    world.push_precollected(world.create_item("Place Indicators"))
    world.push_precollected(world.create_item("Chains Door"))
