class_name Module
extends Node2D


# Used to keep track of the modules that were connected to each of the connectors.
# Keys are the connectors (Connector) values are the modules (Module).
var connected_modules := {}

# The initial positions of the colliders used for repositioning.
var colldider_positions := []
var colldider_rotations := []

onready var connections := $Connections
onready var colliders := $CollisionBoxes.get_children()


func _ready():
	# Add all the collision boxes from the module to the player (/owner).
	if not get_parent().owner is CollisionObject2D:
		print("The onwer of the module is not a CollisionObject2D, therefore it can not use the colliders.")
		return
	for i in range(colliders.size()):
		var collider = colliders[i]
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
	for connector in connections.get_children():
		if connector.direction == direction:
			return connector
	return null

# Returns true if two connectors can connect to each other.
# (They are able to connect, if the are opposite of each other).
func can_connect(connector: Connector, other_connector: Connector) -> bool:
	return true

func connect_module(other_module: Module, connector: Connector, other_connector: Connector) -> void:
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
