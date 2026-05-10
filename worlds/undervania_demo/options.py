from dataclasses import dataclass

from Options import Choice, OptionGroup, PerGameCommonOptions, Range, Toggle

class Route(Choice):
    """
    The route you want to take.
    """

    display_name = "Route"

    option_genocide = 0
    option_neutral = 1
    option_allbosses = 2

    default = option_neutral

@dataclass
class UVDemoOptions(PerGameCommonOptions):
    route: Route

option_groups = [
    OptionGroup(
        "Gameplay Options",
        [Route],
    ),
]
