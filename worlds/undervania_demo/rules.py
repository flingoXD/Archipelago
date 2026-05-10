from __future__ import annotations

from typing import TYPE_CHECKING

from rule_builder.options import OptionFilter
from rule_builder.rules import Has, HasAll, Rule

# from .options import HardMode

if TYPE_CHECKING:
    from .world import UVDemoWorld

# HAS_KEY = Has("Key")


def set_all_rules(world: UVDemoWorld) -> None:

    set_all_entrance_rules(world)
    set_all_location_rules(world)
    set_completion_condition(world)


def set_all_entrance_rules(world: UVDemoWorld) -> None:
    print("Hi2")
    
def set_all_location_rules(world: UVDemoWorld) -> None:
    print("Hi2")

def set_completion_condition(world: UVDemoWorld) -> None:
    print("Hi2")
