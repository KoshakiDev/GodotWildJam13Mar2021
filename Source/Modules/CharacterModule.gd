class_name CharacterModule
extends ModuleWrapper


# This needs to be here so the cosntructor fo the super class is called properly.
func _init(module: Module).(module):
	yield(module, "ready")
	module.enable_module_character_button()
