extends Module

export var thrust_force := 150

func use(_event: InputEvent):
	owner.apply_impulse($Connections/Connector.position,
		Vector2.UP.rotated(owner.rotation) * thrust_force)
