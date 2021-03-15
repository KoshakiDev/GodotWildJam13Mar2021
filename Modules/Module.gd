class_name Module
extends Node2D


enum Type {
	Passive,
	Active,
}

# The mass this module will add to the body
export var mass: float = 0
# The amount of energy this module reserves (reduces max_energy of the player).
export var energey_reserved: float = 0
# The amount of energy this modules consumes when activated (only for active modules).
export var energy_consumption: float = 0

export(Type) var module_type: int = 0

# Used to keep track of the modules that were connected to each of the connectors.
# Keys are the connectors (Connector) values are the modules (Module).
var connected_modules := {}

# The initial positions of the colliders used for repositioning.
var colldider_positions := []
var colldider_rotations := []


onready var connections := $Connections.get_children()
onready var colliders := $CollisionBoxes.get_children()


## Override functions:

# Called whenever this module should be used (only for active-type modules).
func use(_event: InputEvent):
	pass


func _ready():
	# Check if the owner is a CollisionObject2D, as colliders are added.
	# get_parent is used, as the module doesn't necessarily have an owner when
	# entering the tree (always has a parent when in the tree).
	if not get_parent().owner is CollisionObject2D:
		print("The onwer of the module is not a CollisionObject2D, therefore it can not use the colliders.")
		return
	
	# Add all the collision boxes from the module to the player (/the owner).
	for i in range(colliders.size()):
		var collider = colliders[i]
		# Only add actual Colliders to the parent, no clutter.
		if collider is CollisionShape2D or collider is CollisionPolygon2D:
			# Save the initial position (offset to origin).
			colldider_positions.append(collider.position)
			# Save the initial rotation.
			colldider_rotations.append(collider.rotation)
			# Reparent the collider to the player (Rigidbody2D).
			Globals.reparent_node(collider, get_parent().owner)

# When the module is removed, also remove it's colliders from the player.
func _exit_tree():
	for collider in colliders:
		collider.queue_free()

# Returns the first match for a connector with the specified direction.
# Returns null if none are found.
func get_connector_in(direction: Vector2) -> Connector:
	for connector in connections:
		if connector.direction == direction:
			return connector
	return null

# Returns true if a connector from this module and another connector can connect
# to each other.
func can_connect(own_connector: Connector, other_connector: Connector) -> bool:
	return not connected_modules.has(own_connector) and own_connector.can_connect(other_connector)

# Connects another module to this one, at connector (needs to be present in this
# module) and other_connector (needs to be present in other_module).
# Rotates and positions the other_module according to the connectors.
func connect_module(other_module: Module, connector: Connector, other_connector: Connector) -> void:
	assert(connector in connections)
	assert(other_connector in other_module.connections)
	if can_connect(connector, connector):
		# Set the position of the other module to connect the two points (the other
		# module will be repositioned, not this one).
		other_module.reposition(global_position +
			connector.global_position - other_connector.global_position,
			connector.direction.angle() + other_connector.direction.angle()
		)
		connected_modules[connector] = other_module
		other_module.connected_modules[other_connector] = self
		print("Connected %s to %s" % [other_module.name, name])
	else:
		print("ERROR: Tried to connect two modules, that can't be connected with each other.")

# Positions the module and its colliders to new_position (a global_position).
func reposition(new_position: Vector2, new_rotation: float):
	global_position = new_position
	rotation = new_rotation
	for i in range(colliders.size()):
		var collider = colliders[i]
		collider.set_deferred("global_position", new_position + colldider_positions[i].rotated(new_rotation))
		collider.set_deferred("rotation", new_rotation + colldider_rotations[i])
