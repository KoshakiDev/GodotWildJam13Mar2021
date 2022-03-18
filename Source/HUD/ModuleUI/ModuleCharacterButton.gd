extends Area2D

signal module_pressed()


func _on_ModuleCharacterButton_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_released("left_click"):
		emit_signal("module_pressed")
