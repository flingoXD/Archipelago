from dataclasses import dataclass

from Options import Choice, OptionGroup, PerGameCommonOptions, Range, Toggle

class Idk(Choice):
    """
    Placeholder option
    """

    display_name = "Placeholder option"

    option_hi = 0
    option_q = 1
    option_agdfgs = 2

    default = option_hi

@dataclass
class VardrainOptions(PerGameCommonOptions):
    idk: Idk

option_groups = [
    OptionGroup(
        "Gameplay Options",
        [Idk],
    ),
]
