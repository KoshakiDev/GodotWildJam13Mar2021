extends Viewport


const ROTATION_SPEED := 2.5

var rotation_dir := 0.0

onready var bounding_box := Rect2(0, 0, size.x, size.y)
onready var modules_node := $Modules
onready var camera := $Camera2D

func _unhandled_input(event):
	if event is InputEventMouse:
		if bounding_box.has_point(event.position):
			$Camera2D.input_event(event)
	elif event.is_action_pressed("rotate_character_left"):
		rotation_dir -= ROTATION_SPEED
	elif event.is_action_pressed("rotate_character_right"):
		rotation_dir += ROTATION_SPEED
	elif event.is_action_released("rotate_character_left"):
		rotation_dir += ROTATION_SPEED
	elif event.is_action_released("rotate_character_right"):
		rotation_dir -= ROTATION_SPEED
	elif event.is_action_pressed("reset_cam"):
		modules_node.rotation = 0
		camera.position = Vector2.ZERO

func _process(delta):
	modules_node.rotation += rotation_dir * delta


func _on_Viewport_size_changed():
	bounding_box = Rect2(0, 0, size.x, size.y)
	print(bounding_box)
