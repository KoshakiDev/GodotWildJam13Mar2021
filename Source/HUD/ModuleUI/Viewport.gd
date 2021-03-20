extends Viewport


onready var bounding_box := Rect2(0, 0, size.x, size.y)

func _unhandled_input(event):
	if event is InputEventMouse:
		if bounding_box.has_point(event.position):
			$Camera2D.input_event(event)


func _on_Viewport_size_changed():
	bounding_box = Rect2(0, 0, size.x, size.y)
	print(bounding_box)
