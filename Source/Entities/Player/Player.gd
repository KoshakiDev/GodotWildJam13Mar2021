class_name Player
extends RigidBody2D


signal hit_ground()
signal left_ground()


const save_name := "Player.res"


var on_ground: bool = false
var player_save: PlayerSave


onready var module_manager := $ModuleManager
onready var base_weight := weight


func _ready():
	# Hides the indicator for the player as it is meant for the Godot editor only.
	$EditorIndicator.hide()

func _physics_process(delta):
	var hit_ground := test_motion(Vector2.DOWN * 1)
	
	if not on_ground and hit_ground:
		emit_signal("hit_ground")
	elif on_ground and not hit_ground:
		emit_signal("left_ground")
	on_ground = hit_ground
	if on_ground:
		module_manager.refill_energy()

func setup(hud: HUD):
	module_manager.connect("energy_changed", hud, "update_energy_bar")
	module_manager.connect("energy_depleted", hud, "shake_energy_bar")
	module_manager.connect("registered_module", self, "update_mass")
	module_manager.connect("removed_module", self, "update_mass")
	
	connect("hit_ground", module_manager, "refill_energy")
	
	# Load the players data on setup.
	load_data()
	
	module_manager.setup(self)

func save_data():
	if not player_save:
		player_save = PlayerSave.new()
	player_save.position = position
	player_save.rotation = rotation
	SaveManager.save_data(player_save, save_name)

func load_data():
	player_save = SaveManager.load_data(save_name)
	if player_save:
		position = player_save.position
		rotation = player_save.rotation
	else:
		save_data()

func update_mass(_module):
	weight = base_weight + module_manager.accumulated_weight

