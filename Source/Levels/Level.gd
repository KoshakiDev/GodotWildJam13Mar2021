class_name Level
extends Node2D


# Resource that holds the save data of this level. Whenever save is called,
# all children of the level node in the "save" group will have their save_data
# method called with this resource.
var level_save: LevelSave

onready var hud := $UILayer/HUD
onready var module_ui := $UILayer/ModuleUI
onready var spawn_position := $SpawnPosition
onready var entities := $Entities

func _ready():
	# If the data could not be loaded, create new level data and save it (both
	# done by the save method).
	if not load_data():
		save_data()
	
	entities.add_child(Globals.player)
	Globals.player.global_position = spawn_position.global_position
	Globals.player.setup(hud)
	
	module_ui.setup(Globals.player)

func save_data():
	if not level_save:
		level_save = LevelSave.new()
	for node in get_tree().get_nodes_in_group("save"):
		if is_a_parent_of(node):
			node.save_data(level_save)
	
	SaveManager.save_data(level_save, name + ".res")

func load_data() -> bool:
	level_save = SaveManager.load_data(name + ".res")
	if not level_save:
		return false
	for node in get_tree().get_nodes_in_group("save"):
		if is_a_parent_of(node):
			node.load_data(level_save)
	return true
