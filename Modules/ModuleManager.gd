class_name ModuleManager
extends Node2D


func _ready():
	print(Vector2.LEFT.angle())
	var head: Module = $PlayerHead
#	var leg: Module = $BouncyLeg
#	head.connect_module(leg, head.get_connector_in(Vector2.DOWN), leg.get_connector_in(Vector2.UP))
