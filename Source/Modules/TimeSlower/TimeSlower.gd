extends Module

export(float, 0, 1) var time_slow_factor = .5

var old_time_scale: float

func toggle(active: bool):
	if active:
		old_time_scale = Engine.time_scale
	Engine.time_scale = time_slow_factor if active else old_time_scale
	print("Time slow toggled")
