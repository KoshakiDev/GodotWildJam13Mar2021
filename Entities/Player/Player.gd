class_name Player
extends RigidBody2D


signal hit_ground()
signal left_ground()

export var max_linear_velocity := Vector2(500, -1)


var on_ground: bool = false

func _physics_process(delta):
	if max_linear_velocity.x >= 0:
		linear_velocity.x = min(linear_velocity.x, max_linear_velocity.x)
	if max_linear_velocity.y >= 0:
		linear_velocity.y = min(linear_velocity.y, max_linear_velocity.y)
	
	var hit_ground := test_motion(Vector2.DOWN * 5)
	
	if not on_ground and hit_ground:
		emit_signal("hit_ground")
	elif on_ground and not hit_ground:
		emit_signal("left_ground")
	on_ground = hit_ground

func setup(hud: HUD):
	$ModuleManager.connect("energy_changed", hud, "update_energy_bar")
	connect("hit_ground", $ModuleManager, "refill_energy")
