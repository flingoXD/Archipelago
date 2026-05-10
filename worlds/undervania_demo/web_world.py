from BaseClasses import Tutorial
from worlds.AutoWorld import WebWorld

from .options import option_groups

class UVDemoWebWorld(WebWorld):
    game = "Undervania Demo"
    theme = "grassFlowers"
    setup_en = Tutorial(
        "Multiworld Setup Guide",
        "A guide to setting up APQuest for MultiWorld.",
        "English",
        "setup_en.md",
        "setup/en",
        ["NewSoupVi"],
    )
    setup_de = Tutorial(
        "Multiworld Setup Guide",
        "A guide to setting up APQuest for MultiWorld.",
        "German",
        "setup_de.md",
        "setup/de",
        ["NewSoupVi"],
    )

    tutorials = [setup_en, setup_de]

    option_groups = option_groups
