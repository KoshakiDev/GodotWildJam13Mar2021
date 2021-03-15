class_name ZoomCamera2D
extends Camera2D


export var zoom_speed: float = .2
export var zoom_duration: float = .2
export var min_zoom: float = .5
export var max_zoom: float = 2


var dragging := false
# Saves the position where one started dragging
var drag_start_position := Vector2.ZERO

var zoom_level: float = 1.0 setget set_zoom_level


onready var tween := $Tween

func _input(event) -> void:
	# When right or middle clicking, start the dragging.
	if event.is_action_pressed("right_click") or event.is_action_pressed("middle_click"):
		dragging = true
		drag_start_position = get_local_mouse_position()
	# When right or middle is released, stop the dragging.
	elif event.is_action_released("right_click") or event.is_action_released("middle_click"):
		dragging = false
	# If the mouse is moved and you are dragging, 
	elif event is InputEventMouseMotion and dragging:
		position -= event.relative * zoom_level
	elif event.is_action_pressed("zoom_in"):
		set_zoom_level(zoom_level - zoom_speed)
	elif event.is_action_pressed("zoom_out"):
		set_zoom_level(zoom_level + zoom_speed)

func set_zoom_level(val: float) -> void:
	zoom_level = clamp(val, min_zoom, max_zoom)
	
	tween.interpolate_property(
		self,
		"zoom",
		zoom,
		Vector2(zoom_level, zoom_level),
		zoom_duration,
		tween.TRANS_SINE,
		tween.EASE_OUT
	)
	tween.start()

