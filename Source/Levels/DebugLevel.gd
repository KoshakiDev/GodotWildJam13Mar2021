extends Node2D


onready var hud := $UILayer/HUD
onready var module_ui := $UILayer/ModuleUI
onready var player := $Player

func _ready():
	player.setup(hud)
	module_ui.setup(player)
