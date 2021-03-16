class_name ModuleContainer
extends Reference


var character_module: CharacterModule
var inventory_module: InventoryModule
var world_module: WorldModule

# Used to keep track of the modules that were connected to e[ach of the connectors.
# Keys are the connectors (Connector) values are Arrays that look like this:
# [0]: the connected module (ModuleContainer)
# [1]: the connected connector (Connector)
var connected_modules := {}

# The weight this module will add to the body
var weight: float
# The amount of energy this modules consumes when activated (only for active modules).
var energy_consumption: float
# The amount of energy this module reserves (reduces max_energy of the player).
var energy_reserved: float

var module_type: int

var use_action: String

func _init(module: Module) -> void:
	world_module = WorldModule.new(module)
	inventory_module = InventoryModule.new(module.duplicate())
	character_module = CharacterModule.new(module.duplicate())
	
	weight = module.weight
	energy_consumption = module.energy_consumption
	energy_reserved = module.energy_reserved
	module_type = module.module_type
	use_action = module.use_action

# Returns true if a connector from this module and another connector can connect
# to each other.
func can_connect(own_connector: Connector) -> bool:
	return not get_world_connector(own_connector) in connected_modules

func get_connectors() -> Array:
	return world_module.module.connectors

func get_character_connector(connector: Connector) -> Connector:
	return character_module.module.get_connector_by_name(connector.name)

func get_inventory_connector(connector: Connector) -> Connector:
	return inventory_module.module.get_connector_by_name(connector.name)

func get_world_connector(connector: Connector) -> Connector:
	return world_module.module.get_connector_by_name(connector.name)

func connect_module(connector: Connector, other_module: ModuleContainer, other_connector: Connector):
	if can_connect(connector) and other_module.can_connect(other_connector):
		# Check if the actual modules have the same parent. If they don't, reparent
		# the other module to this modules parent.
		var character_parent = character_module.module.get_parent()
		if character_parent:
			if character_parent != other_module.character_module.module.get_parent():
				Globals.reparent_node(other_module.character_module.module, character_parent)
				print("Merged parents of modules")
		else:
			printerr("Error while merging parents in ModuleContainer (character).")
		# Connect the character modules
		character_module.call_deferred("connect_module",
			get_character_connector(connector),
			other_module.character_module,
			other_module.get_character_connector(other_connector)
		)
		
		# Check if the actual modules have the same parent. If they don't, reparent
		# the other module to this modules parent.
		var world_parent = world_module.module.get_parent()
		if world_parent:
			if world_parent != other_module.world_module.module.get_parent():
				Globals.reparent_node(other_module.world_module.module, world_parent)
		else:
			printerr("Error while merging parents in ModuleContainer (world).")
		# Connect the world modules
		world_module.call_deferred("connect_module",
			get_world_connector(connector),
			other_module.world_module,
			other_module.get_world_connector(other_connector)
		)
		
		# Add the module to the connected_modules dictionary
		connected_modules[get_world_connector(connector)] = [
			other_module,
			other_module.get_world_connector(other_connector)
		]
		other_module.connected_modules[other_module.get_world_connector(other_connector)] = [
			self,
			get_world_connector(connector)
		]
	else:
		print("Cannot connect ModuleContainers %s and %s" % 
			[world_module.module.name, other_module.world_module.module.name])

func get_module_connected_to(connector: Connector) -> ModuleContainer:
	return connected_modules[connector][0]

func get_connector_connected_to(connector: Connector) -> Connector:
	return connected_modules[connector][1]

func disconnect_module(connector: Connector) -> void:
	# If the connector is connected to nothing, ignore it.
	if not get_world_connector(connector) in connected_modules:
		return
	# Get the other module and connector, before disconnecting
	var other_module: ModuleContainer = connected_modules[get_world_connector(connector)][0]
	var other_connector: Connector = connected_modules[get_world_connector(connector)][1]
	
	# Disconnect both sides of the connection.
	_disconnect_connector(connector)
	other_module._disconnect_connector(other_connector)

func _disconnect_connector(connector: Connector):
	# Set the connected states of own connectors to false.
	var world_connector = get_world_connector(connector)
	world_connector.connected = false
	get_character_connector(connector).connected = false
	connected_modules.erase(world_connector)
