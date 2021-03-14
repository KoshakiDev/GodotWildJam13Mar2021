extends Module

export var roll_speed: float = 100
export(float, 0, 1) var roll_weight := .1


func _physics_process(delta):
	var dir := Vector2.ZERO
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	owner.applied_force.x = dir.x * roll_speed
