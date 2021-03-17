extends VBoxContainer


signal module_selected(module, connector)
signal module_deselected()
signal connector_hovered(connector_type, hovered)


const item_panel_scene := preload("res://Source/HUD/ModuleUI/ItemPanel.tscn")

# Array to keep track of modules that exist in the players inventory.
var modules = {}

var selected_module: ModuleContainer
var selected_connector: Connector

var stop_connectors: bool = false


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

# Highlights all connectors of the given type, if active is true, removes the
# highlight if it is false.
func highlight_connectors(connector_type: int, active: bool) -> void:
	for module in modules:
		for connector in module.get_connectors():
			if not active or connector.connection_type == connector_type:
				module.get_inventory_connector(connector).set_highlight(active)

func on_Character_module_registered(module: ModuleContainer) -> void:
	deselect(false)
	remove_item(module)

func on_connector_toggled(toggled, module, connector) -> void:
	# If the currently selected connector is toggled of, remove its selection.
	if stop_connectors:
		return
	# Always deselect the selected connector, when one is clicked
	deselect(true)
	# Select the connector that is clicked.
	if toggled:
		selected_module = module
		selected_connector = connector
		emit_signal("module_selected", module, connector)

func deselect(emit_signal: bool):
	# This stops the selected_connector in on_connector_toggled; fixes a weird bug.
	stop_connectors = true
	# This also sets the selected connector / module to null, as the 
	# on_connector_toggled is called and resets those values.
	if selected_connector:
		selected_connector.connector_button.pressed = false
	selected_module = null
	selected_connector = null
	stop_connectors = false
	if emit_signal:
		emit_signal("module_deselected")

func on_connector_hovered(connector: Connector, hovered: float):
	emit_signal("connector_hovered", connector.connection_type, hovered)
