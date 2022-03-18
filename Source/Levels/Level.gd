class_name Level
extends Node2D


# Resource that holds the save data of this level. Whenever save is called,
# all children of the level node in the "save" group will have their save_data
# method called with this resource.
var level_save: LevelSave

onready var ui_layer := $UILayer
onready var spawn_position := $SpawnPosition
onready var entities := $Entities

func _ready() -> void:
	# If the data could not be loaded, create new level data and save it (both
	# done by the save method).
	if not Globals.current_level:
		Globals.create_objects()
		Globals.current_level = self
	
	load_data()
	
	entities.add_child(Globals.player)
	
	Globals.reparent_node(Globals.hud, ui_layer)
	Globals.reparent_node(Globals.module_ui, ui_layer)
	
	Globals.player.load_data()
	
	if Globals.player.position == Vector2.ZERO:
		Globals.player.global_position = spawn_position.global_position

func save_data() -> void:
	if not level_save:
		level_save = LevelSave.new()
	for node in get_tree().get_nodes_in_group("save"):
		if is_a_parent_of(node):
			node.save_data(level_save)
	
	SaveManager.save_data(level_save, name + ".res")

func load_data() -> void:
	level_save = SaveManager.load_data(name + ".res")
	if level_save:
		for node in get_tree().get_nodes_in_group("save"):
			if is_a_parent_of(node):
				node.load_data(level_save)
	else:
		save_data()
