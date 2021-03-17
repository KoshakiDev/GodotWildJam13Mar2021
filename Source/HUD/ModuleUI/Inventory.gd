extends VBoxContainer


signal module_selected(module, connector)
signal module_deselected()
signal connector_hovered(connector_type)


const item_panel_scene := preload("res://Source/HUD/ModuleUI/ItemPanel.tscn")

# Array to keep track of modules that exist in the players inventory.
var modules = {}


onready var item_grid := $MarginContainer/ScrollContainer/ItemGrid


func setup():
	var thruster := preload("res://Source/Modules/Thruster/SmallThruster.tscn").instance()
	var thruster_module = ModuleContainer.new(thruster)
	add_item(thruster_module)
	
	var anti_grav := preload("res://Source/Modules/GravityNuller/GravityNuller.tscn").instance()
	var anti_grav_module = ModuleContainer.new(anti_grav)
	add_item(anti_grav_module)
	
	var time_slow := preload("res://Source/Modules/TimeSlower/TimeSlower.tscn").instance()
	var time_slow_module = ModuleContainer.new(time_slow)
	add_item(time_slow_module)

func add_item(module: ModuleContainer):
	# If the module was already added, readd it to the grid (saves resources).
	if module in modules:
		item_grid.add_child(modules[module])
		add_module_connectors(module)
		return
	
	var new_item = item_panel_scene.instance()
	item_grid.add_child(new_item)
	new_item.setup(module.inventory_module.module)
	
	modules[module] = new_item
	
	add_module_connectors(module)

func add_module_connectors(module: ModuleContainer):
	for connector in module.get_connectors():
		module.get_inventory_connector(connector).generate_connector_button(self, module)

func remove_item(module: ModuleContainer):
	# Return if the module isn't added
	if not module in modules:
		return
	
	# Remove the ItemPanel from the inventory.
	item_grid.remove_child(modules[module])
	
	for connector in module.get_connectors():
		module.get_inventory_connector(connector).delete_connector_button()

func on_connector_toggled(toggled, module, connector) -> void:
	if toggled:
		emit_signal("module_selected", module, connector)
	else:
		emit_signal("module_deselected")

func on_connector_hovered() -> void:
	pass
