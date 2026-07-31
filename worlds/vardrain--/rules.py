from __future__ import annotations

from typing import TYPE_CHECKING

from rule_builder.options import OptionFilter
from rule_builder.rules import Has, HasAll, Rule, CanReachEntrance, CanReachLocation

# from .options import HardMode

if TYPE_CHECKING:
    from .world import VardrainWorld

# HAS_KEY = Has("Key")

def set_all_rules(world: VardrainWorld) -> None:

    set_all_entrance_rules(world)
    set_all_location_rules(world)
    set_completion_condition(world)


def set_all_entrance_rules(world: VardrainWorld) -> None:
    epilogue = world.get_entrance("Epilogue Entrance")
    world.set_rule(epilogue, CanReachLocation("Tutorial Complete") & CanReachLocation("Hello World Complete")
                   & CanReachLocation("Can You Die Already Complete") & CanReachLocation("The Hordes... Part 1 Complete")
                   & CanReachLocation("The Hordes... Part 2 Complete") & CanReachLocation("A Doozy, Heh Part 1 Complete")
                   & CanReachLocation("A Doozy, Heh Part 2 Complete") & CanReachLocation("Pushin' & Pullin' Complete")
                   & CanReachLocation("Stairs Part 1 Complete") & CanReachLocation("Stairs Part 2 Complete")
                   & CanReachLocation("\"Hardcore\" platforming Part 1 Complete") & CanReachLocation("\"Hardcore\" platforming Part 2 Complete")
                   & CanReachLocation("Invisible path Complete") & CanReachLocation("Sisyphus Part 1 Complete")
                   & CanReachLocation("Sisyphus Part 2 Complete") & CanReachLocation("Catapult frenzy Part 1 Complete")
                   & CanReachLocation("Catapult frenzy Part 2 Complete") & CanReachLocation("Impossible Part 1 Complete")
                   & CanReachLocation("Impossible Part 2 Complete"))
    
def set_all_location_rules(world: VardrainWorld) -> None:
    tut = world.get_location("Tutorial Complete")
    lv1 = world.get_location("Hello World Complete")
    lv2 = world.get_location("Can You Die Already Complete")
    lv3p1 = world.get_location("The Hordes... Part 1 Complete")
    lv3p2 = world.get_location("The Hordes... Part 2 Complete")
    lv4p1 = world.get_location("A Doozy, Heh Part 1 Complete")
    lv4p2 = world.get_location("A Doozy, Heh Part 2 Complete")
    lv5 = world.get_location("HELLevator!! Complete")
    lv6 = world.get_location("Pushin' & Pullin' Complete")
    lv7p1 = world.get_location("Stairs Part 1 Complete")
    lv7p2 = world.get_location("Stairs Part 2 Complete")
    lv8p1 = world.get_location("\"Hardcore\" platforming Part 1 Complete")
    lv8p2 = world.get_location("\"Hardcore\" platforming Part 2 Complete")
    lv9 = world.get_location("Invisible path Complete")
    lv10p1 = world.get_location("Sisyphus Part 1 Complete")
    lv10p2 = world.get_location("Sisyphus Part 2 Complete")
    lv11p1 = world.get_location("Catapult frenzy Part 1 Complete")
    lv11p2 = world.get_location("Catapult frenzy Part 2 Complete")
    lv12p2 = world.get_location("Impossible Part 1 Complete")
    lv12p3 = world.get_location("Impossible Part 2 Complete")
    # lv13 = world.get_location("Damn It Complete")

    world.set_rule(tut, Has("Vertical Scale Blocks"))
    world.set_rule(lv1, HasAll("Push Platforms", "Vertical Scale Blocks"))
    world.set_rule(lv2, HasAll("Bombs", "Push Platforms"))
    world.set_rule(lv3p1, HasAll("Push Blocks", "Push Platforms", "Bombs"))
    world.set_rule(lv3p2, HasAll("Fragile Blocks", "Enemy Life"))
    world.set_rule(lv4p1, HasAll("Ropes", "KillRope Thickness"))
    world.set_rule(lv4p2, Has("Vertical Scale Blocks"))
    world.set_rule(lv5, Has("Vertical Scale Blocks"))
    world.set_rule(lv6, HasAll("Push Blocks", "Vertical Scale Blocks", "Ropes",
                               "Moveable Platforms", "Bombs", "KillRope Thickness",
                               "Deactivateable Platforms", "Pull Blocks",
                               "Fragile Blocks", "Push Platforms", "Place Indicators"))
    world.set_rule(lv7p1, HasAll("Vertical Scale Blocks", "Push Blocks"))
    world.set_rule(lv7p2, Has("Vertical Scale Blocks"))
    world.set_rule(lv8p1, HasAll("Cannons", "Chains Door", "Moveable Platforms",
                                 "Push Blocks"))
    world.set_rule(lv8p2, HasAll("Chains Door", "Vertical Scale Blocks", "Cannons",
                                 "Bombs", "Moveable Platforms", "Place Indicators"))
    world.set_rule(lv9, HasAll("Enemy Life", "Deactivateable Platforms", "Push Blocks",
                               "Place Indicators"))
    world.set_rule(lv10p1, HasAll("Push Blocks", "Push Platforms", "Ropes"))
    world.set_rule(lv10p2, HasAll("Push Blocks", "Pull Blocks", "Push Platforms",
                                  "Place Indicators"))
    world.set_rule(lv11p1, HasAll("Cannons", "Fragile Blocks", "Pull Blocks"))
    world.set_rule(lv11p2, HasAll("Cannons", "Moveable Platforms"))
    # Level Impossible IS possible without killing any enemies but it's tough
    world.set_rule(lv12p2, HasAll("Push Platforms", "Vertical Scale Blocks", "KillRope Thickness"))
    world.set_rule(lv12p3, HasAll("Cannons", "Push Platforms", "KillRope Thickness"))

def set_completion_condition(world: VardrainWorld) -> None:
    # For Now
    world.set_completion_rule(Has("Damn It Complete"))
