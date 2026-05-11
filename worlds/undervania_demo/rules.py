from __future__ import annotations

from typing import TYPE_CHECKING

from rule_builder.options import OptionFilter
from rule_builder.rules import Has, HasAll, Rule, CanReachRegion

# from .options import HardMode

if TYPE_CHECKING:
    from .world import UVDemoWorld

# HAS_KEY = Has("Key")

has_weapon = Has("Stick") | Has("Toy Knife")
has_act = Has("Act - Talk") | Has("Act - Cheer") | Has("Act - Threat")

def set_all_rules(world: UVDemoWorld) -> None:

    set_all_entrance_rules(world)
    set_all_location_rules(world)
    set_completion_condition(world)


def set_all_entrance_rules(world: UVDemoWorld) -> None:
    sw_ot = world.get_entrance("Old Tomb Savepoint")
    world.set_rule(sw_ot,HasAll("Strytax's Sword","Glide"))
    sw_dr = world.get_entrance("Dark Ruins Savepoint")
    wr_dr = world.get_entrance("West Ruins to Dark Ruins")
    world.set_rule(sw_dr,has_act)
    world.set_rule(wr_dr,has_act)
    sw_dc = world.get_entrance("Dark Caves Savepoint")
    sw_er = world.get_entrance("Home Savepoint")
    er_dc = world.get_entrance("Home Tower Door")
    dc_dr = world.get_entrance("Dark Caves Exit")
    wr_er = world.get_entrance("West Ruins Exits")
    east_ruins_rules = Has("Glide") | Has("Act - Talk")
    world.set_rule(sw_er,east_ruins_rules)
    world.set_rule(sw_dc,east_ruins_rules)
    world.set_rule(wr_er,east_ruins_rules)
    
def set_all_location_rules(world: UVDemoWorld) -> None:
    ss1 = world.get_location("Spider Store 1")
    ss2 = world.get_location("Spider Store 2")
    fr = world.get_location("Faded Ribbon")
    world.set_rule(fr, Has("Napstablook Defeated"))
    world.set_rule(ss1, Has("Napstablook Defeated"))
    world.set_rule(ss2, Has("Napstablook Defeated"))
    napst = world.get_location("Napstablook Defeated")
    world.set_rule(napst, Has("Act - Cheer"))
    gp = world.get_location("Golden Pear")
    world.set_rule(gp,Has("Micro Froggit Defeated"))
    mc = world.get_location("Monster Candy")
    world.set_rule(mc, has_weapon)
    wings = world.get_location("Wings")
    world.set_rule(wings, Has("Decibat Defeated"))
    rtr = world.get_location("Raffle Ticket Rewards")
    world.set_rule(rtr, Has("Toriel Defeated"))
    tori = world.get_location("Toriel Defeated")
    world.set_rule(tori, Has("Glide") | Has("Act - Talk"))
    cc = world.get_location("Candy Corn")
    world.set_rule(cc, Has("Glide"))
    tc = world.get_location("Tutorial Chest")
    world.set_rule(tc, has_weapon)
    #rc = world.get_location("Rock Candy")
    #world.set_rule(rc, CanReachRegion("West Dark Ruins"))
    #c = [world.get_location("Corn Maze Chest"),
         #world.get_location("Home Large Room Chest"),
         #world.get_location("Tutorial Chest"),
         #world.get_location("Cheer Room Chest"),
         #world.get_location("Old Tomb Chest")]
    #for i in c:
        #world.set_rule(i,Has("Stick") | Has("Toy Knife"))

def set_completion_condition(world: UVDemoWorld) -> None:
    # For Now
    world.set_completion_rule(HasAll("Decibat Defeated","Micro Froggit Defeated",
        "Toriel Defeated","Strytax Defeated","Napstablook Defeated"))
