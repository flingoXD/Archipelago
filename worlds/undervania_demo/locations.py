from __future__ import annotations

from typing import TYPE_CHECKING

from BaseClasses import ItemClassification, Location

from . import items

if TYPE_CHECKING:
    from .world import UVDemoWorld

LOCATION_NAME_TO_ID = {
    "Candy Corn": 1,
    "Corn Dog": 2,
    "Strytax's Sword": 3,
    "Faded Ribbon": 4,
    "Golden Pear": 5,
    "Lemonade": 6,
    "Monster Candy": 7,
    "Buy Raffle Ticket": 8,
    "Raffle Ticket Rewards": 9,
    "Pie": 10,
    "Rock Candy": 11,
    "Shadow Amulet": 12,
    "Spider Store 1": 13,
    "Spider Store 2": 14,
    "Toy Knife": 15,
    "Act - Talk": 16,
    "Act - Cheer": 17,
    "Act - Threat": 18,
    "Act - Check": 19,
    "Wings": 20,
}

class UVDemoLocation(Location):
    game = "Undervania Demo"

def get_location_names_with_ids(location_names: list[str]) -> dict[str, int | None]:
    return {location_name: LOCATION_NAME_TO_ID[location_name] for location_name in location_names}


def create_all_locations(world: UVDemoWorld) -> None:
    create_regular_locations(world)
    create_events(world)


def create_regular_locations(world: UVDemoWorld) -> None:
    save_warp = world.get_region("Save Warp")
    old_tomb = world.get_region("Old Tomb")
    west_ruins = world.get_region("West Ruins")
    east_ruins = world.get_region("East Ruins/Home")
    west_dark_ruins = world.get_region("West Dark Ruins")
    dark_caves = world.get_region("Dark Caves")
    
    old_tomb.add_locations(get_location_names_with_ids(
        ["Shadow Amulet"]
    ), UVDemoLocation)
    east_ruins.add_locations(get_location_names_with_ids(
        ["Pie", "Act - Threat", "Toy Knife"]
    ), UVDemoLocation)
    west_ruins.add_locations(get_location_names_with_ids(
        ["Buy Raffle Ticket", "Raffle Ticket Rewards", "Act - Talk", "Act - Cheer","Faded Ribbon","Spider Store 1", "Spider Store 2","Monster Candy"]
    ), UVDemoLocation)
    dark_caves.add_locations(get_location_names_with_ids(
        ["Golden Pear","Strytax's Sword"]
    ), UVDemoLocation)
    west_dark_ruins.add_locations(get_location_names_with_ids(
        ["Rock Candy", "Wings", "Act - Check", "Corn Dog", "Lemonade", "Candy Corn"]
    ), UVDemoLocation)


def create_events(world: UVDemoWorld) -> None:
    print("hi!")
    #
    #
    ###
    # #
    # # my chair
