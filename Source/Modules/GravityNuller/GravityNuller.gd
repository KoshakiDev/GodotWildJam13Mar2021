extends Module


export var gravity_scale: float = 0

var old_gravity_scale: float

func toggle(active: bool):
	if active:
		old_gravity_scale = _body.gravity_scale
	_body.set_gravity_scale(gravity_scale if active else old_gravity_scale)
	print("Antigravity toggled")
