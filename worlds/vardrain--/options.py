from dataclasses import dataclass

from Options import Choice, OptionGroup, PerGameCommonOptions, DefaultOnToggle

class StartWithVSBlocks(DefaultOnToggle):
    """
    Choose to start with or without Vertical Scale Blocks. This will probably break generation if you turn it off.
    """
    display_name = "Start With Vertical Scale Blocks"

class StartWithChainsDoor(DefaultOnToggle):
    """
    Choose to start with or without the Chains Door. This will probably break generation if you turn it off.
    """
    display_name = "Start With Chains Door"

class StartWithPlaceIndicators(DefaultOnToggle):
    """
    Choose to start with or without Place Indicators. This will probably break generation if you turn it off.
    """
    display_name = "Start With Chains Door"

@dataclass
class VardrainOptions(PerGameCommonOptions):
    start_with_vertical_scale_blocks: StartWithVSBlocks
    start_with_chains_door: StartWithChainsDoor
    start_with_place_indicators: StartWithPlaceIndicators

option_groups = [
    OptionGroup(
        "Starting Abilities",
        [StartWithVSBlocks, StartWithChainsDoor, StartWithPlaceIndicators],
    ),
]
