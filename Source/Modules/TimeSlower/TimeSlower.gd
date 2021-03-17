extends Module

onready var timer: Timer = $Timer

func use(_event: InputEvent):
	Engine.set_time_scale(0.5)
	timer.start()


func _on_Timer_timeout():
	Engine.set_time_scale(1)
