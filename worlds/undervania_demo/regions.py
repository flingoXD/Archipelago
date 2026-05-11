from __future__ import annotations

from typing import TYPE_CHECKING

from BaseClasses import Entrance, Region

if TYPE_CHECKING:
    from .world import UVDemoWorld

def create_and_connect_regions(world: UVDemoWorld) -> None:
    create_all_regions(world)
    connect_regions(world)


def create_all_regions(world: UVDemoWorld) -> None:
    save_warp = Region("Save Warp", world.player, world.multiworld)
    old_tomb = Region("Old Tomb", world.player, world.multiworld)
    west_ruins = Region("West Ruins", world.player, world.multiworld)
    east_ruins = Region("East Ruins/Home", world.player, world.multiworld)
    west_dark_ruins = Region("West Dark Ruins", world.player, world.multiworld)
    dark_caves = Region("Dark Caves", world.player, world.multiworld)
    
    regions = [save_warp, old_tomb, east_ruins, west_ruins, west_dark_ruins, dark_caves]

    world.multiworld.regions += regions


def connect_regions(world: UVDemoWorld) -> None:
    save_warp = world.get_region("Save Warp")
    old_tomb = world.get_region("Old Tomb")
    west_ruins = world.get_region("West Ruins")
    east_ruins = world.get_region("East Ruins/Home")
    west_dark_ruins = world.get_region("West Dark Ruins")
    dark_caves = world.get_region("Dark Caves")

    # placeholders
    save_warp.connect(old_tomb,"Old Tomb Savepoint")
    save_warp.connect(west_ruins,"West Ruins Savepoint")
    save_warp.connect(west_dark_ruins,"Dark Ruins Savepoint")
    save_warp.connect(dark_caves,"Dark Caves Savepoint")
    save_warp.connect(east_ruins,"Home Savepoint")
    east_ruins.connect(dark_caves,"Home Tower Door")
    dark_caves.connect(west_dark_ruins,"Dark Caves Exit")
    west_dark_ruins.connect(west_ruins,"Dark Ruins Exits")
    west_ruins.connect(east_ruins,"West Ruins Exits")
    west_ruins.connect(west_dark_ruins,"West Ruins to Dark Ruins")
    
