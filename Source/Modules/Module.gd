class_name Module
extends Node2D


enum Type {
	Passive,
	Active,
	Toggled,
}

# The weight this module will add to the body
export var weight: float = 0
# The amount of energy this module reserves (reduces max_energy of the player).
export var energy_reserved: float = 0
# The amount of energy this modules consumes when activated.
# For toggled modules this is the amount of energy consumed each second.
# This only affects Active and Toggled modules.
export var energy_consumption: float = 0

export(Type) var module_type: int = 0

# The name that will be displayed in the inventory
export var display_name: String

# Temporary! Will be used when this action is pressed.
export var use_action: String

# Used for in the UI to make modules clickable
export var mouse_collider: NodePath


var connectors := []

var _body: RigidBody2D

var center_position: Position2D

# TODO: remove these as globals and expose functions for their use cases
onready var character_button := $ModuleCharacterButton

## Override functions:

# Called whenever this module should be used (only for active-type modules).
func use(_event: InputEvent) -> void:
	pass

# Called whenerver a toggle-type module is toggled on or off.
func toggle(_state: bool) -> void:
	pass

func physics_process(delta) -> void:
	pass

func setup() -> void:
	connectors = $Connections.get_children()
	center_position = $CenterPosition

func enable_module_character_button() -> void:
	print("inside tree: %s" % is_inside_tree())
	if (not mouse_collider):
		return
	if $ModuleCharacterButton.get_child_count() == 0:
		$ModuleCharacterButton.add_child(get_node(mouse_collider).duplicate())
	$ModuleCharacterButton.input_pickable = true

func disable_module_character_button() -> void:
	$ModuleCharacterButton.input_pickable = false

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
