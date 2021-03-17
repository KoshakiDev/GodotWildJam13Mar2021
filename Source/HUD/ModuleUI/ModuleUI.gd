extends MarginContainer


onready var character_menu := $Panel/MarginContainer/HBoxContainer/Character
onready var inventory_menu := $Panel/MarginContainer/HBoxContainer/Inventory


func _unhandled_input(event):
	if event.is_action_pressed("open_inventory"):
		if not visible:
			show()
			get_tree().paused = true
		else:
			hide()
			get_tree().paused = false

func setup(player: Player):
	character_menu.setup(player.module_manager)
	inventory_menu.setup()
	
	inventory_menu.connect("module_selected", character_menu, "on_Inventory_module_selected")
	inventory_menu.connect("module_deselected", character_menu, "deselect_module")
	inventory_menu.connect("connector_hovered", character_menu, "on_Inventory_hovered")
	
	# If the character menu adds a module, remove it from the inventory,
	# if the character removes a module, add it to the inventory.
	character_menu.connect("module_registered", inventory_menu, "on_Character_module_registered")
	character_menu.connect("module_removed", inventory_menu, "add_item")
	character_menu.connect("connector_hovered", inventory_menu, "highlight_connectors", [true])
	# The 0 bind is needed to satisfy the method signature.
	character_menu.connect("connector_unhovered", inventory_menu, "highlight_connectors", [0, false])
