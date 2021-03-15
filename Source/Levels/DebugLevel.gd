extends Node2D


onready var hud := $CanvasLayer/HUD
onready var player := $Player

func _ready():
	player.setup(hud)
