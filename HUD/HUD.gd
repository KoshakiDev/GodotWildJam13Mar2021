class_name HUD
extends Control


onready var energy_bar := $EnergyBar


func update_energy_bar(energy: float, max_energy: float):
	energy_bar.value = energy / max_energy * 100
	print("Energy updated: %s / %s" % [energy, max_energy])
