class_name Connector
extends Position2D


enum Type {
	Small = 1,
	Medium = 2,
	Big = 4,
}

const connector_button_scene := preload("res://Source/HUD/ModuleUI/ConnectorButton.tscn")
const connector_highlight_style := preload("res://Resources/Themes/Styles/Connector/NormalHighlight.tres")
const connector_normal_style := preload("res://Resources/Themes/Styles/Connector/Normal.tres")

# The direction of this connector as a string, to make it easier to export.
export(String, "Left", "Right", "Up", "Down") var direction_string: String setget set_direction_string

export(Type, FLAGS) var connection_type: int = 2

export var size := Vector2(11, 6)

# The direction of this connector (opposite directions can connect).
var direction := Vector2.ZERO

var connector_button: Button

var connected: bool

# The module this connector belongs to.
var module_container

func delete_connector_button():
	if connector_button:
		connector_button.queue_free()
		connector_button = null

# Generates a connector button for this connector and connects relevant signals to it.
# press_callback needs to look like this: toggle_callback(toggled, module, connector)
# hover_callback needs to look like this: hover_callback(connector, hovering)
func generate_connector_button(node: Node, module_container, toggle_callback := "on_connector_toggled",
hover_callback := "on_connector_hovered", custom_button_scene: PackedScene = connector_button_scene) -> void:
	self.module_container = module_container
	connector_button = custom_button_scene.instance()
	add_child(connector_button)
	connector_button.rect_position = -size
	connector_button.rect_size = size*2
	connector_button.connect("toggled", node, toggle_callback, [module_container, self])
	if hover_callback != "":
		connector_button.connect("mouse_entered", node, hover_callback, [self, true])
		connector_button.connect("mouse_exited", node, hover_callback, [self, false])

func set_highlight(active: bool, custom_highlight_style: StyleBox = connector_highlight_style):
	var style: StyleBox
	if active:
		style = custom_highlight_style
	else:
		style = connector_normal_style
	# Set the style of the connector button.
	if connector_button and connector_button.name.begins_with("ConnectorButton"):
		connector_button.set("custom_styles/normal", style)

# Returns true if this connector can connect to the other connector.
func can_connect(other_connector: Connector) -> bool:
	return connection_type & other_connector.connection_type != 0 and not connected

# Used to set the direction of the connector with export hints.
func set_direction_string(dir: String) -> void:
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

