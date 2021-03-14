extends Module


onready var piston_collider := $CollisionBoxes/CollisionShape2D

func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		piston_collider.
