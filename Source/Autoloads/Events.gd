extends Node


# Emitted whenever a module is picked up.
signal module_picked_up(module_container)

# Emitted whenever the game should save. Connect this to the save functions.
signal game_save_requested()

