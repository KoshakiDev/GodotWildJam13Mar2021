extends Module

export var thrust_force := 150

func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		owner.apply_impulse($Connections/Connector.position,
			Vector2.UP.rotated(owner.rotation) * thrust_force)
