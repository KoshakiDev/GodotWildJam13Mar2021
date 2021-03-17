extends Module

onready var timer: Timer = $Timer

func use(_event: InputEvent):
	_body.set_gravity_scale(0.0)
	timer.start()
	print("Antigravity")

func _on_Timer_timeout():
	_body.set_gravity_scale(1.0)
	print("Gravity back")
