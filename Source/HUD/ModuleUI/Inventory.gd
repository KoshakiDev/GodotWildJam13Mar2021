extends VBoxContainer


signal module_selected(module, connector)
signal module_deselected()
signal connector_hovered(connector_type, hovered)


const save_name := "Inventory.res"

const item_panel_scene := preload("res://Source/HUD/ModuleUI/ItemPanel.tscn")

# Array to keep track of modules that exist in the players inventory.
var modules = {}

var selected_module: ModuleContainer
var selected_connector: Connector

var stop_connectors: bool = false

var inventory_save: InventorySave


onready var item_grid := $MarginContainer/ScrollContainer/ItemGrid


func setup():
	Events.connect("module_picked_up", self, "add_item")
	load_data()


func save_data():
	if not inventory_save:
		inventory_save = InventorySave.new()
	
	inventory_save.modules = []
	for module in modules:
		# Only add the module to the inventory, if it is in the the inventory and
		# not just cashed. This is needed, as modules are keept in the modules
		# array and only removed as a child of the item_grid.
		if item_grid.is_a_parent_of(modules[module]):
			inventory_save.modules.append(module.module_scene_path)
	
	SaveManager.save_data(inventory_save, save_name)


func load_data():
	inventory_save = SaveManager.load_data(save_name)
	if inventory_save:
		for module_path in inventory_save.modules:
			var module: Module = load(module_path).instance()
			var module_container = ModuleContainer.new(module)
			add_item(module_container)
	else:
		save_data()


func add_item(module: ModuleContainer):
	# If the module was already added, re-add it to the grid (saves resources).
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

func on_Character_hovered(connector_type: int, hovered: bool) -> void:
	if selected_connector:
		return
	highlight_connectors(connector_type, hovered)

# Highlights all connectors of the given type, if active is true, removes the
# highlight if it is false.
func highlight_connectors(connector_type: int, active: bool) -> void:
	for module in modules:
		for connector in module.get_connectors():
			if connector.connection_type == connector_type:
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
