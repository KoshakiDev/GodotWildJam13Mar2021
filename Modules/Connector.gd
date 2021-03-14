class_name Connector
extends Position2D


enum Type {
	Small = 1,
	Medium = 2,
	Big = 4,
}

# The direction of this connector as a string, to make it easier to export.
export(String, "Left", "Right", "Up", "Down") var direction_string: String setget set_direction_string

export(Type, FLAGS) var connection_type: int = 2

# The direction of this connector (opposite directions can connect).
var direction := Vector2.ZERO

# Returns true if this connector can connect to the other connector.
func can_connect(other_connector: Connector) -> bool:
	return connection_type & other_connector.connection_type != 0

# Used to set the direction of the connector with export hints.
func set_direction_string(dir: String):
	direction_string = dir
	match dir:
		"Left":
			direction = Vector2.LEFT
		"Right":
			direction = Vector2.RIGHT
		"Up":
			direction = Vector2.UP
		"Down":
			direction = Vector2.DOWN
