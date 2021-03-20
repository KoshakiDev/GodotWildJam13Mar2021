extends Area2D


export var module_scene: PackedScene


var module_container: ModuleContainer


func _ready():
	# Print error if module scene was not set.
	if not module_scene:
		printerr("No module_scene set for module pickup: %s" % name)
	
	# Create module instance.
	var module = module_scene.instance()
	# If the module scene isn't a Module, print an error.
	if not module is Module:
		printerr("Tried to create module pickup from non pickup: %s" % name)
	
	module_container = ModuleContainer.new(module)
	
	$AnimationPlayer.play("floating")


func pickup():
	Events.emit_signal("module_picked_up", module_container)
	# Add an entry with this name to the level_save, to delte it when loading.
	Globals.current_level.level_save.object_data[name] = true
	queue_free()

func save_data(level_save: LevelSave):
	# Nothing needs to be done here, as the level_save is modified in the
	# pickup method. This cannot be done here as the node is deleted.
	pass

func load_data(level_save: LevelSave):
	# If there is an entry with this name in the save and it is set to true, delete
	# this node, as it has already been picked up.
	if name in level_save.object_data and level_save.object_data[name]:
		queue_free()

func _on_ModulePickup_body_entered(body):
	if body is Player:
		pickup()
