from __future__ import annotations

from typing import TYPE_CHECKING

from BaseClasses import Entrance, Region

if TYPE_CHECKING:
    from .world import VardrainWorld

def create_and_connect_regions(world: VardrainWorld) -> None:
    create_all_regions(world)
    connect_regions(world)


def create_all_regions(world: VardrainWorld) -> None:
    level_select = Region("Level Select", world.player, world.multiworld)
    levels = Region("Levels", world.player, world.multiworld)
    epilogue = Region("Epilogue", world.player, world.multiworld)
    
    regions = [level_select, levels, epilogue]

    world.multiworld.regions += regions


def connect_regions(world: VardrainWorld) -> None:
    level_select = world.get_region("Level Select")
    levels = world.get_region("Levels")
    epilogue = world.get_region("Epilogue")

    level_select.connect(levels, "Levels Entrance")
    level_select.connect(epilogue, "Epilogue Entrance")
    
