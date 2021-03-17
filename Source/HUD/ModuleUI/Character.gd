extends VBoxContainer


signal module_registered(module)
signal module_removed(module)
signal connector_hovered(connector_type)
signal connector_unhovered()


# Array to keep track of all the modules (ModuleContainer) that are in the
# character screen.
var modules := []

# The main module the Character screen is centered around.
var module_manager: ModuleManager

var selected_module: ModuleContainer
var selected_connector: Connector


onready var viewport := $MarginContainer/ViewportContainer/Viewport


func setup(module_manager: ModuleManager) -> void:
	self.module_manager = module_manager
	# Clear the modules, if they exist already.
	if modules.size() > 0:
		for module_key in modules:
			module_key.queue_free()
		modules.clear()
		print("Cleared modules in Character tab.")
	
	for module in module_manager.modules:
		register_module(module)

func register_module(module: ModuleContainer) -> void:
	if module in modules:
		print("Module is already registered in character modules.")
		return
	
	modules.append(module)
	viewport.add_child(module.character_module.module)
	
	update_connectors(module)
	
	emit_signal("module_registered", module)

func on_connector_toggled(toggled: bool, module: ModuleContainer, connector: Connector) -> void:
	if selected_module and selected_connector and toggled and connector.can_connect(selected_connector):
		print("Clicked on connector: %s" % connector.name)
#		print("Connecting %s to %s" % [selected_module.name, module.name])
		# Connects the selected module (from inventory) with the module that was
		# pressed in the character tab.
		register_module(selected_module)
		module_manager.register_module(selected_module, selected_module.use_action)
		
		module.call_deferred("connect_module",
			connector,
			selected_module,
			selected_connector
		)
		
		# Remove the connection buttons from the now connected modules.
		module.get_character_connector(connector).delete_connector_button()
		selected_module.get_character_connector(selected_connector).delete_connector_button()
		
		selected_module.get_character_connector(selected_connector).generate_connector_button(
			self,
			selected_module,
			"on_disconnector_toggled",
			"",
			preload("res://Source/HUD/ModuleUI/DisconnectorButton.tscn")
		)
		
		# Deselect the selected module, when done, so you can't connect it again.
		deselect_module()
	# Only do this, when the button is not being removed.
	else:
		# Set the toggle buttons state to be unpressed again (behaves like a normal
		# button that way)
		connector.connector_button.pressed = false

func update_connectors(module: ModuleContainer, no_delete := false) -> void:
	for connector in module.get_connectors():
		# If the connector already has a button, dont add a new one.
		connector = module.get_character_connector(connector)
		if no_delete and connector.connector_button:
			print("skipping connector")
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
	# Don't highlight anything, if a module is selected.
	if selected_module:
		return
	if hovered:
		emit_signal("connector_hovered", connector.connection_type)
	else:
		emit_signal("connector_unhovered")

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
	viewport.remove_child(module.character_module.module)
	emit_signal("module_removed", module)

