from BaseClasses import Tutorial
from worlds.AutoWorld import WebWorld

from .options import option_groups

class VardrainWebWorld(WebWorld):
    game = "vardrain--"
    theme = "stone"
    setup_en = Tutorial(
        "Multiworld Setup Guide",
        "A guide to setting up vardrain-- for MultiWorld.",
        "English",
        "setup_en.md",
        "setup/en",
        ["flingo"],
    )

    tutorials = [setup_en]

    option_groups = option_groups
