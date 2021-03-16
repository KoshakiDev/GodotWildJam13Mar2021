class_name WorldModule
extends ModuleWrapper


# The initial positions of the colliders used for repositioning.
var colldider_positions := []
var colldider_rotations := []

var colliders := []


# This needs to be here so the cosntructor fo the super class is called properly.
func _init(module: Module).(module):
	pass

func setup(body: RigidBody2D) -> void:
	module._body = body
	add_colliders_to(body)

func use(event: InputEvent) -> void:
	module.use(event)

func connect_module(connector: Connector, other_module: ModuleWrapper, other_connector: Connector) -> void:
	print("Connecting in world:")
	.connect_module(connector, other_module, other_connector)

func add_colliders_to(body: RigidBody2D) -> void:
	if colliders.empty():
		colliders = module.get_node("CollisionBoxes").get_children()
	# Add all the collision boxes from the module to the body.
	for i in range(colliders.size()):
		var collider = colliders[i]
		# Only add actual Colliders to the parent, no clutter.
		if collider is CollisionShape2D or collider is CollisionPolygon2D:
			# Save the initial position (offset to origin).
			colldider_positions.append(collider.position)
			# Save the initial rotation.
			colldider_rotations.append(collider.rotation)
			# Reparent the collider to the player (Rigidbody2D).
			Globals.reparent_node(collider, body)

# When the module is removed, also remove it's colliders from the player.
func _on_module_exit_tree() -> void:
	if not colliders:
		return
	for collider in colliders:
		Globals.reparent_node(collider, module.get_node("CollisionBoxes"))
#		collider.queue_free()

func reposition(new_position: Vector2, new_rotation: float):
	.reposition(new_position, new_rotation)
	for i in range(colliders.size()):
		var collider = colliders[i]
		collider.set_deferred("position", new_position + colldider_positions[i].rotated(new_rotation))
		collider.set_deferred("rotation", new_rotation + colldider_rotations[i])

func set_module(new_module: Module) -> void:
	if module:
		module.disconnect("tree_exiting", self, "_on_module_exit_tree")
	.set_module(new_module)
	module.connect("tree_exiting", self, "_on_module_exit_tree")
	print("Set module in world_module")
