extends PanelContainer


var display_module: Module


onready var viewport := $MarginContainer/VBoxContainer/ViewportContainer/Viewport
onready var name_label := $MarginContainer/VBoxContainer/NameLabel


func setup(module: Module):
	display_module = module
	# Add the module to the viewport so it is visible.
	viewport.add_child(display_module)
	# Make the module slightly see-through.
	display_module.modulate.a = 1
	# Make the module a bit bigger.
	display_module.scale *= 2
	# Place the module in the middle of the viewport.
	var corrected_viewport_position = viewport.size/2 - Vector2(10, 20)
	display_module.position = corrected_viewport_position - display_module.center_position.position
	# Update the name label to show the modules name.
	name_label.text = module.display_name
