extends Area2D

export var thrust_force = 300

func _ready():
	pass

func _on_KnockbackArea_body_entered(body):
	var impulse:Vector2 = body.global_position - self.global_position
	impulse = impulse.normalized() * thrust_force
	body.linear_velocity = Vector2.ZERO
	body.apply_central_impulse(impulse)
	
