extends Node2D

onready var polygon = $Polygon2D
onready var body = $StaticBody2D
onready var collision_polygon = $StaticBody2D/CollisionPolygon2D

func _ready():
	collision_polygon.polygon = polygon.polygon
