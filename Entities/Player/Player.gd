extends RigidBody2D


export var max_linear_velocity := Vector2(500, -1)


func _physics_process(delta):
	if max_linear_velocity.x >= 0:
		linear_velocity.x = min(linear_velocity.x, max_linear_velocity.x)
	if max_linear_velocity.y >= 0:
		linear_velocity.y = min(linear_velocity.y, max_linear_velocity.y)
