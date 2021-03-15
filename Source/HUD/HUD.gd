class_name HUD
extends Control


onready var energy_bar := $EnergyBar
onready var tween := $Tween


func update_energy_bar(energy: float, max_energy: float):
#	energy_bar.value = energy / max_energy * 100
	var new_val = energy / max_energy * 100
	tween.stop(energy_bar, 'value')
	tween.interpolate_property(
		energy_bar, 'value',
		energy_bar.value, new_val,
		.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func shake_energy_bar():
	tween.interpolate_property(
		energy_bar.get_material(), 'shader_param/offset',
		1.0, 0.0,
		.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
