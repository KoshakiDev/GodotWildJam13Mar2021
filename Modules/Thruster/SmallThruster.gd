extends Module

export var thrust_force := 100

func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		print("Thrust in %s" % owner.rotation)
		owner.apply_impulse($Connections/Connector.position, Vector2.UP.rotated(owner.rotation) * thrust_force)
