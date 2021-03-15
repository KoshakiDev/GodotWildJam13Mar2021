extends Module

# The force of the thrust (impulse that is applied).
export var thrust_force := 150
# Limits the linear velocity of the body to this value. This functions as a 
# stop to momentum in a direction, lets the thruster have more of an impact,
# if the player is moving at high speeds (as the speed will be capped and the impulse
# will be applied afterwards).
export var linear_clamp := 200

func use(_event: InputEvent):
	
	var impulse := Vector2.UP.rotated(owner.rotation) * thrust_force
	
	if impulse.angle_to(owner.linear_velocity) > PI/2:
		# Limit the linear velocity (see linear_clamp above).
		owner.linear_velocity = owner.linear_velocity.clamped(linear_clamp)
	
	# Apply the impulse to the player.
	owner.apply_impulse($Connections/Connector.position, impulse)
	
	# Play the thrust animation to show the flame of the thruster
	$AnimationPlayer.play("thrust")
