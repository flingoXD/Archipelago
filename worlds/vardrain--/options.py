from dataclasses import dataclass

from Options import Choice, Range, OptionGroup, PerGameCommonOptions, DefaultOnToggle, DeathLink

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
    display_name = "Start With Place Indicators"
class DeathLinkAmnesty(Range):
    """
    How many deaths or restarts it takes to trigger a DeathLink
    """
    display_name = "Death Link Amnesty"
    range_start = 1
    range_end = 20
    default = 10

@dataclass
class VardrainOptions(PerGameCommonOptions):
    start_with_vertical_scale_blocks: StartWithVSBlocks
    start_with_chains_door: StartWithChainsDoor
    start_with_place_indicators: StartWithPlaceIndicators
    death_link: DeathLink
    death_link_amnesty: DeathLinkAmnesty

option_groups = [
    OptionGroup(
        "Starting Abilities",
        [StartWithVSBlocks, StartWithChainsDoor, StartWithPlaceIndicators],
    ),
    OptionGroup(
        "DeathLink",
        [DeathLink, DeathLinkAmnesty],
    ),
]
