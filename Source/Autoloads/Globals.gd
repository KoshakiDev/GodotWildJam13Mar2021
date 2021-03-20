extends Node

var current_level: Level

var player: Player
var hud: HUD
var module_ui


func _init():
	player = preload("res://Source/Entities/Player/Player.tscn").instance()

func _ready():
	Events.connect("game_save_requested", self, "save_data")

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		Events.emit_signal("game_save_requested")

func save_data():
	if current_level:
		current_level.save_data()
		player.save_data()

func reparent_node(node: Node, new_parent: Node, custom_owner: Node = null) -> void:
	var old_parent = node.get_parent()
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
