class_name Module
extends Node2D


enum Type {
	Passive,
	Active,
}

# The weight this module will add to the body
export var weight: float = 0
# The amount of energy this module reserves (reduces max_energy of the player).
export var energy_reserved: float = 0
# The amount of energy this modules consumes when activated (only for active modules).
export var energy_consumption: float = 0

export(Type) var module_type: int = 0

# The name that will be displayed in the inventory
export var display_name: String

# Temporary! Will be used when this action is pressed.
export var use_action: String


var connectors := []

var _body: RigidBody2D

var center_position: Position2D

## Override functions:

# Called whenever this module should be used (only for active-type modules).
func use(_event: InputEvent):
	pass

func physics_process(delta):
	pass

func setup() -> void:
	connectors = $Connections.get_children()
	center_position = $CenterPosition

# Returns the first match for a connector with the specified direction.
# Returns null if none are found.
func get_connector_in(direction: Vector2) -> Connector:
	for connector in connectors:
		if connector.direction == direction:
			return connector
	return null

func get_connector_by_name(name: String) -> Connector:
	for connector in connectors:
		if connector.name == name:
			return connector
	return null
