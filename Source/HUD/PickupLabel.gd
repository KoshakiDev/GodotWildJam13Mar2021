extends Label


const pickup_text := "You have picked up a %s module!"


# Time the pickup text will be visible for until it starts fading away.
export var visible_time := 1.0
# Time the pickup text will take to fade away completely.
export var fade_time := 1.0


onready var timer := $Timer
onready var tween := $Tween


func _ready():
	Events.connect("module_picked_up", self, "on_pickup")
	hide()

func on_pickup(module_container: ModuleContainer):
	tween.stop_all()
	# Set the pickup text with the name of the module that was picked up.
	text = pickup_text % module_container.display_name
	# Reset the alpha value so it is visible.
	modulate.a = 1.0
	# Show the pickup label on the screen.
	show()
	
	timer.start(visible_time)


func _on_Timer_timeout():
	tween.interpolate_property(self, "modulate:a", modulate.a, 0, fade_time,
		Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()


func _on_Tween_tween_completed(object, key):
	if object == self and key == ":modulate:a":
		hide()
