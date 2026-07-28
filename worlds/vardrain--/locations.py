from __future__ import annotations

from typing import TYPE_CHECKING

from BaseClasses import ItemClassification, Location

from . import items

if TYPE_CHECKING:
    from .world import VardrainWorld

LOCATION_NAME_TO_ID = {
    "Tutorial Complete": 1,
    "Hello World Complete": 2,
    "Can You Die Already Complete": 3,
    "The Hordes... Part 2 Complete": 4,
    "A Doozy, Heh Part 1 Complete": 5,
    "HELLevator!! Complete": 6,
    "Pushin' & Pullin' Complete": 7,
    "Stairs Part 2 Complete": 8,
    "\"Hardcore\" platforming Part 1 Complete": 9,
    "\"Hardcore\" platforming Part 2 Complete": 10,
    "Invisible path Complete": 11,
    "Sisyphus Part 2 Complete": 12,
    "Catapult frenzy Part 2 Complete": 13,
    "Impossible Part 2 Complete": 14,
    "Sisyphus Part 1 Complete": 15,
    "Catapult frenzy Part 1 Complete": 16,
    "Stairs Part 1 Complete": 17,
    "The Hordes... Part 1 Complete": 18,
    "Impossible Part 1 Complete": 19,
    "A Doozy, Heh Part 2 Complete": 20,
    "Impossible Part 3 Complete": 21,
}

class VardrainLocation(Location):
    game = "vardrain--"

def get_location_names_with_ids(location_names: list[str]) -> dict[str, int | None]:
    return {location_name: LOCATION_NAME_TO_ID[location_name] for location_name in location_names}


def create_all_locations(world: VardrainWorld) -> None:
    create_regular_locations(world)
    create_events(world)


def create_regular_locations(world: VardrainWorld) -> None:
    levels = world.get_region("Levels")
    epilogue = world.get_region("Epilogue")
    levels.add_locations(get_location_names_with_ids([
        "Tutorial Complete",
        "Hello World Complete",
        "Can You Die Already Complete",
        "The Hordes... Part 2 Complete",
        "A Doozy, Heh Part 1 Complete",
        "HELLevator!! Complete",
        "Pushin' & Pullin' Complete",
        "Stairs Part 2 Complete",
        "\"Hardcore\" platforming Part 1 Complete",
        "\"Hardcore\" platforming Part 2 Complete",
        "Invisible path Complete",
        "Sisyphus Part 2 Complete",
        "Catapult frenzy Part 2 Complete",
        "Impossible Part 2 Complete",
        "Sisyphus Part 1 Complete",
        "Catapult frenzy Part 1 Complete",
        "Stairs Part 1 Complete",
        "The Hordes... Part 1 Complete",
        "Impossible Part 1 Complete",
        "A Doozy, Heh Part 2 Complete",
        "Impossible Part 3 Complete"
    ]), VardrainLocation)
def create_events(world: VardrainWorld) -> None:
    epilogue = world.get_region("Epilogue")
    epilogue.add_event("Damn It Complete", "Damn It Complete",
                       location_type=VardrainLocation,
                       item_type=items.VardrainItem)
