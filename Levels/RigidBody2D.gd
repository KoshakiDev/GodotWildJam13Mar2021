extends RigidBody2D

export var distance: float = 100


var extended := false
var finished := true
var original_position: Vector2

onready var tween := $Tween

func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		if not extended and finished:
			print("Jumping")
			original_position = position
			finished = false
			extended = true
			tween.interpolate_property(self, "position", position, 
			position + (Vector2.DOWN*distance).rotated(rotation), .5, Tween.TRANS_CUBIC, Tween.EASE_IN)
			tween.start()

func _on_Tween_tween_completed(object, key):
	if object == self and key == ":position":
		if extended:
			tween.interpolate_property(self, "position", position, 
				original_position, .5, Tween.TRANS_CUBIC, Tween.EASE_IN)
			tween.start()
			extended = false
		else:
			finished = true
