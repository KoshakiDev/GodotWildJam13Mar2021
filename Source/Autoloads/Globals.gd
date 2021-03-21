extends Node


const save_name := "Global.res"


var current_level: Level
var last_played_level: PackedScene

var player: Player
var hud: HUD
var module_ui

var global_save: GlobalSave


func _ready():
	player = preload("res://Source/Entities/Player/Player.tscn").instance()
	hud = preload("res://Source/HUD/HUD.tscn").instance()
	module_ui = preload("res://Source/HUD/ModuleUI/ModuleUI.tscn").instance()
	
	add_child(player)
	add_child(hud)
	add_child(module_ui)
	
	player.setup(hud)
	module_ui.setup(player)
	
	remove_child(player)
	remove_child(hud)
	remove_child(module_ui)
	
	load_data()
	Events.connect("game_save_requested", self, "save_data")

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		Events.emit_signal("game_save_requested")


func save_data() -> void:
	if not global_save:
		global_save = GlobalSave.new()
	if current_level:
		global_save.last_played_level_path = current_level.filename
		# Save the data of the levela and the player.
		current_level.save_data()
		player.save_data()
	else:
		global_save.last_played_level_path = ""
	SaveManager.save_data(global_save, save_name)

func load_data() -> void:
	global_save = SaveManager.load_data(save_name)
	if global_save:
		var last_played_level_path: String = global_save.last_played_level_path
		if last_played_level_path != "":
			last_played_level = load(last_played_level_path)
	else:
		save_data()

func reparent_node(node: Node, new_parent: Node, custom_owner: Node = null) -> void:
	var old_parent = node.get_parent()
	if old_parent == new_parent:
		return
	if old_parent:
		old_parent.call_deferred("remove_child", node)
	new_parent.call_deferred("add_child", node)
	if custom_owner:
		node.set_deferred("owner", custom_owner)
	else:
		node.set_deferred("owner", new_parent)

func change_level(level: Level):
	# If there is a current level, save it. It is then loaded in the Level._ready()
	# function.
	if current_level:
		current_level.save_data()
		# Remove the player from the current level so it isn't deleted when the level is.
		# The player is then added to the next level in Level._ready().
		if current_level.is_a_parent_of(player):
			player.get_parent().remove_child(player)
		if current_level.is_a_parent_of(hud):
			hud.get_parent().remove_child(hud)
		if current_level.is_a_parent_of(module_ui):
			module_ui.get_parent().remove_child(module_ui)
	change_scene(level)
	current_level = level

func change_scene(new_scene : Node):
	var root = get_tree().get_root()
	var current = get_tree().current_scene
	if new_scene == current:
		printerr("Cant change scene to scene you are in!")
		return
	root.call_deferred("remove_child", current)
	current.call_deferred("free")
	root.call_deferred("add_child", new_scene)
	# Optional, to make it compatible with the SceneTree.change_scene() API.
	get_tree().call_deferred("set_current_scene", new_scene)
