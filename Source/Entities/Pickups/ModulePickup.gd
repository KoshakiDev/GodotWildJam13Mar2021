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
	queue_free()


func _on_ModulePickup_body_entered(body):
	if body is Player:
		pickup()
