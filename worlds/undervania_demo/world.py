from collections.abc import Mapping
from typing import Any

from worlds.AutoWorld import World

from . import items, locations, regions, rules, web_world
from . import options as uvdemo_options  # rename due to a name conflict with World.options

class UVDemoWorld(World):
    """
    APQuest is a minimal 8bit-era inspired adventure game with grid-like movement.
    Good games don't need more than six checks.
    """

    game = "Undervania Demo"

    web = web_world.UVDemoWebWorld()

    options_dataclass = uvdemo_options.UVDemoOptions
    options: uvdemo_options.UVDemoOptions  # Common mistake: This has to be a colon (:), not an equals sign (=).

    location_name_to_id = locations.LOCATION_NAME_TO_ID
    item_name_to_id = items.ITEM_NAME_TO_ID

    origin_region_name = "Save Warp"

    def create_regions(self) -> None:
        regions.create_and_connect_regions(self)
        locations.create_all_locations(self)

    def set_rules(self) -> None:
        rules.set_all_rules(self)

    def create_items(self) -> None:
        items.create_all_items(self)

    def create_item(self, name: str) -> items.UVDemoItem:
        return items.create_item_with_correct_classification(self, name)

    def get_filler_item_name(self) -> str:
        return items.get_random_filler_item_name(self)

    def fill_slot_data(self) -> Mapping[str, Any]:

        return self.options.as_dict(
            "route"
        )
