extends VBoxContainer


signal module_registered(module)
signal module_removed(module)
signal connector_hovered(connector_type, hovered)



const save_name := "Character.res"

# Array to keep track of all the modules (ModuleContainer) that are in the
# character screen.
var modules := []

# The main module the Character screen is centered around.
var module_manager: ModuleManager

var selected_module: ModuleContainer
var selected_connector: Connector

var character_save: CharacterSave


onready var viewport := $MarginContainer/ViewportContainer/Viewport
onready var modules_node: Node2D = $MarginContainer/ViewportContainer/Viewport/Modules


func setup(module_manager: ModuleManager) -> void:
	self.module_manager = module_manager
	# Clear the modules, if they exist already.
	if modules.size() > 0:
		for module_key in modules:
			module_key.queue_free()
		modules.clear()
	
	for module in module_manager.modules:
		register_module(module)
	
	load_data()

func save_data():
	if not character_save:
		character_save = CharacterSave.new()
	
	character_save.modules = {}
	for module in modules:
		module.save_character_data(character_save)
	
	SaveManager.save_data(character_save, save_name)

func load_data():
	character_save = SaveManager.load_data(save_name)
	if character_save:
		load_module(module_manager.main_module, character_save)
	else:
		save_data()

func load_module(module_container: ModuleContainer, 
character_save: CharacterSave, ignore_connector := "") -> void:
	var connection_save: Dictionary = character_save.modules[module_container.name]
	# If there are now connections, stop the recursion.
	if connection_save.empty():
		return
	
	# Go over all connections, create the other module and connect it.
	# Then load that module.
	for connector_name in connection_save:
		# If the connector should be ignored, ignore it. This is used to ignore
		# the connector the module was created from.
		if connector_name == ignore_connector:
			continue
		
		var connector_arr = connection_save[connector_name]
		var other_module = load(connector_arr[0]).instance()
		var other_container = ModuleContainer.new(other_module)
		var other_connector_name = connector_arr[1]
		
		connect_modules(
			module_container,
			module_container.get_connector_by_name(connector_name),
			other_container,
			other_container.get_connector_by_name(other_connector_name)
		)
		
		load_module(other_container, character_save, other_connector_name)

func register_module(module: ModuleContainer) -> void:
	if module in modules:
		print("Module is already registered in character modules.")
		return
	
	modules.append(module)
	modules_node.add_child(module.character_module.module)
	
	update_connectors(module)
	
	emit_signal("module_registered", module)

func on_connector_toggled(toggled: bool, module: ModuleContainer, connector: Connector) -> void:
	if selected_module and selected_connector and toggled and connector.can_connect(selected_connector):
		connect_modules(module, connector, selected_module, selected_connector)
		# Deselect the selected module, when done, so you can't connect it again.
		deselect_module()
		# Only do this, when the button is not being removed.
	else:
		# Set the toggle buttons state to be unpressed again (behaves like a normal
		# button that way)
		connector.connector_button.pressed = false

func connect_modules(module: ModuleContainer, connector: Connector,
other_module: ModuleContainer, other_connector: Connector) -> void:
	if connector.can_connect(other_connector):
#		print("Connecting %s to %s" % [other_module.name, module.name])
		# Connects the selected module (from inventory) with the module that was
		# pressed in the character tab.
		register_module(other_module)
		module_manager.register_module(other_module, other_module.use_action)
		
		module.call_deferred("connect_module",
			connector,
			other_module,
			other_connector
		)
		
		# Remove the connection buttons from the now connected modules.
		module.get_character_connector(connector).delete_connector_button()
		other_module.get_character_connector(other_connector).delete_connector_button()
		
		other_module.get_character_connector(other_connector).generate_connector_button(
			self,
			other_module,
			"on_disconnector_toggled",
			"",
			preload("res://Source/HUD/ModuleUI/DisconnectorButton.tscn")
		)

func update_connectors(module: ModuleContainer, no_delete := false) -> void:
	for connector in module.get_connectors():
		# If the connector already has a button, dont add a new one.
		connector = module.get_character_connector(connector)
		if no_delete and connector.connector_button:
			continue
		connector.delete_connector_button()
		if not connector.connected:
			connector.generate_connector_button(self, module)

func on_disconnector_toggled(toggled: bool, module: ModuleContainer, connector: Connector) -> void:
	if toggled:
		# Disconnect the modules from each other
		var connected_module = module.get_module_connected_to(module.get_world_connector(connector))
		var connected_connector = module.get_connector_connected_to(module.get_world_connector(connector))
		module.disconnect_module(connector)
		connected_module.disconnect_module(connected_connector)
		
		# Remove the module from the world and character tab.
		module_manager.remove_module(module)
		remove_module(module)
		
		module.get_character_connector(connector).delete_connector_button()
		
		# Update all the connector buttons, without deleting old ones.
		for module in modules:
			update_connectors(module, true)
	# Only do this, when the button is not being removed.
	else:
		# Set the toggle buttons state to be unpressed again (behaves like a normal
		# button that way)
		connector.connector_button.pressed = false

func on_connector_hovered(connector: Connector, hovered: float) -> void:
#	# Don't highlight anything, if a module is selected.
#	if selected_module:
#		return
	emit_signal("connector_hovered", connector.connection_type, hovered)

func on_Inventory_hovered(connector_type: int, hovered: bool) -> void:
	if selected_connector and selected_connector.connection_type == connector_type:
		return
	highlight_connectors(connector_type, hovered)
	# If there is a selected connector and nothing is hovered anymore, rehighlight
	# the selections connectors.
	if selected_connector:
		highlight_connectors(selected_connector.connection_type, not hovered)

# Highlights all connectors of the given type, if active is true, removes the
# highlight if it is false.
func highlight_connectors(connector_type: int, active: bool) -> void:
	for module in modules:
		for connector in module.get_connectors():
			if connector.connection_type == connector_type:
				module.get_character_connector(connector).set_highlight(active)

func on_Inventory_module_selected(module: ModuleContainer, connector: Connector) -> void:
	selected_module = module
	selected_connector = connector
	# Highlight respective connectors when selecting a module.
	highlight_connectors(selected_connector.connection_type, true)

func deselect_module() -> void:
	if not (selected_connector and selected_module):
		return
	# Remove the highlight on the respective connectors.
	highlight_connectors(selected_connector.connection_type, false)
	# Unset the selected module and connector.
	selected_module = null
	selected_connector = null

func remove_module(module: ModuleContainer) -> void:
	if not module in modules:
		print("Tried to remove non-existent module in character menu: %s" % module.name)
		return
	modules.erase(module)
	modules_node.remove_child(module.character_module.module)
	emit_signal("module_removed", module)

