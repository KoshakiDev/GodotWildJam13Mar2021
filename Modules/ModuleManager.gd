class_name ModuleManager
extends Node2D


func _ready():
	print(Vector2.LEFT.angle())
	var head: Module = $PlayerHead
	var thruster: Module = $Thruster
	head.connect_module(thruster, head.get_connector_in(Vector2.DOWN),
		thruster.get_connector_in(Vector2.UP))
