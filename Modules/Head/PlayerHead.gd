extends Module

export var roll_speed: float = 150
export var rotation_speed: float = 5
export(float, 0, 1) var rotation_accel := .1


func _physics_process(delta):
	var dir: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	var rotate_dir: float = Input.get_action_strength("rotate_right") - Input.get_action_strength("rotate_left")
	
#	owner.add_force(Vector2.ZERO, Vector2.RIGHT * dir * roll_speed)
	
	if rotate_dir:
#		if not owner.test_motion(Vector2.DOWN * 5):
		owner.angular_velocity = lerp(owner.angular_velocity, rotate_dir * rotation_speed / owner.mass, rotation_accel)
