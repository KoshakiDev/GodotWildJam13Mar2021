class_name Player
extends RigidBody2D


signal hit_ground()
signal left_ground()


var on_ground: bool = false


onready var module_manager := $ModuleManager
onready var base_weight := weight


func _physics_process(delta):
	var hit_ground := test_motion(Vector2.DOWN * 1)
	
	if not on_ground and hit_ground:
		emit_signal("hit_ground")
	elif on_ground and not hit_ground:
		emit_signal("left_ground")
	on_ground = hit_ground
	if on_ground:
		module_manager.refill_energy()

func setup(hud: HUD):
	module_manager.connect("energy_changed", hud, "update_energy_bar")
	module_manager.connect("energy_depleted", hud, "shake_energy_bar")
	module_manager.connect("registered_module", self, "update_mass")
	module_manager.connect("removed_module", self, "update_mass")
	
	connect("hit_ground", module_manager, "refill_energy")
	
	module_manager.setup(self)

func update_mass(_module):
	weight = base_weight + module_manager.accumulated_weight
