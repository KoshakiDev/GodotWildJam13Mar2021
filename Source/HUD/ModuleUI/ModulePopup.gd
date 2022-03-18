extends PopupPanel


# The name of the module
var module_name: String
# A list of keybinds that can be set, should be an array of Dictionaries
# with {name, displayname}
var module_keybinds: Array
# A list of values for the module that should have a slider
var module_sliders: Array
# A list of values for the module that should have a numeric value
var module_nums: Array

func set_module(module: ModuleContainer) -> void:
	module_name = module.display_name
	
	update_ui()

func update_ui() -> void:
	$MarginContainer/VBoxContainer/ModuleName.text = module_name
	
