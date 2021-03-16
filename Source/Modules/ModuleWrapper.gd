class_name ModuleWrapper
extends Reference


var module: Module setget set_module


func _init(module: Module):
	set_module(module)
	module.setup()

func get_connectors() -> Array:
	return module.connectors

# Connects another module to this one, at connector (needs to be present in this
# module) and other_connector (needs to be present in other_module).
# Rotates and positions the other_module according to the connectors.
func connect_module(connector: Connector, other_module_wrapper: ModuleWrapper, other_connector: Connector) -> void:
	assert(connector in module.connectors)
	assert(other_connector in other_module_wrapper.module.connectors)
	# Set the position of the other module to connect the two points (the other
	# module will be repositioned, not this one).
	print("mgp: %s, cgp: %s, ocgp: %s" % [module.global_position, connector.position, other_connector.position])
	other_module_wrapper.reposition(module.global_position +
		connector.position - other_connector.position,
		connector.direction.angle() + other_connector.direction.angle()
	)
	connector.connected = true
	other_connector.connected = true
	print("Connected %s to %s" % [other_module_wrapper.module.name, module.name])

func disconnect_connector(connector: Connector) -> void:
	connector.connected = false

# Positions the module and its colliders to new_position (a global_position).
func reposition(new_position: Vector2, new_rotation: float):
	module.global_position = new_position
	module.rotation = new_rotation

func set_module(new_module: Module) -> void:
	module = new_module
