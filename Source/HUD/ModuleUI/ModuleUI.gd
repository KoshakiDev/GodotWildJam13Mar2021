extends MarginContainer


var _player: Player


onready var character_menu := $Panel/MarginContainer/HBoxContainer/Character
onready var inventory_menu := $Panel/MarginContainer/HBoxContainer/Inventory


func _unhandled_input(event):
	if event.is_action_pressed("open_inventory"):
		if not visible:
			show()
			get_tree().paused = true
			character_menu.modules_node.rotation = _player.rotation
		else:
			hide()
			get_tree().paused = false

func save_data():
	inventory_menu.save_data()
	character_menu.save_data()

func setup(player: Player):
	# Save the player to get it's rotation.
	_player = player
	
	Events.connect("game_save_requested", self, "save_data")
	
	# Setup the character and inventory part of the UI.
	character_menu.setup(player.module_manager)
	inventory_menu.setup()
	
	# Connect the inventory signals to the character menu:
	inventory_menu.connect("module_selected", character_menu, "on_Inventory_module_selected")
	inventory_menu.connect("module_deselected", character_menu, "deselect_module")
	inventory_menu.connect("connector_hovered", character_menu, "on_Inventory_hovered")
	
	# Connect the character signals to the inventory menu:
	character_menu.connect("module_registered", inventory_menu, "on_Character_module_registered")
	character_menu.connect("module_removed", inventory_menu, "add_item")
	# When a 
	character_menu.connect("connector_hovered", inventory_menu, "on_Character_hovered")
