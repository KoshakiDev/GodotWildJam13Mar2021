class_name Connector
extends Position2D


# The direction of this connector as a string, to make it easier to export.
export(String, "Left", "Right", "Up", "Down") var direction_string: String setget set_direction_string

# The direction of this connector (opposite directions can connect).
var direction := Vector2.ZERO

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
