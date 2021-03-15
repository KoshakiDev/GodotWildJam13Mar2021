class_name ModuleManager
extends Node2D

# Emitted whenever the module energy changes.
signal energy_changed(energy, max_energy)


# Maximum energy.
export var max_energy := 100

# Mass of all the modules together.
var accumulated_mass: float
# Current energy.
var energy: float
# Currently reserved (unusable) energy.
var energy_reserved: float

# Dictionary keeping track of which input action is used for which module.
# Keys are the names of the actions (String), values are modules (Module).
var use_mapping := {}


func _ready() -> void:
	var head: Module = $PlayerHead
	var thruster: Module = $Thruster
	
	# Register the modules.
	register_module(head)
	register_module(thruster, "use_module_1")
	
	# Connect the thruster to the head.
	head.connect_module(thruster, head.get_connector_in(Vector2.DOWN),
		thruster.get_connector_in(Vector2.UP))
	
	# Refill energy initially.
	refill_energy()

func _unhandled_input(event: InputEvent):
	# Check if any of the use_mapping actions are pressed.
	for input_action in use_mapping:
		if event.is_action_pressed(input_action):
			# Use the module associated with this action.
			use_module(use_mapping[input_action], event)


# Registers a module to add its mass, reserved energy and add it's input action.
# Automatically subtracts those values when the module is freed (see _on_module_removed)
func register_module(module: Module, input_action := "") -> void:
	if input_action != "":
		use_mapping[input_action] = module
	accumulated_mass += module.mass
	energy_reserved += module.energey_reserved
	module.connect("tree_exited", self, "_on_module_removed", [module.mass, module.energey_reserved, input_action])

# Is called whenever a module is removed. Changes mass, reserved energy and use_mapping
# to not include that module anymore.
func _on_module_removed(module_mass: float, module_energy_reserved: float, input_action: String) -> void:
	if use_mapping.has(input_action):
		use_mapping.erase(input_action)
	accumulated_mass -= module_mass
	energy_reserved -= module_energy_reserved

# Refills the energy to the full (or to a percentile of the full energy based on
# fill_multiplier) fill_multiplier is capped at 1.0.
func refill_energy(fill_multiplier := 1.0) -> void:
	fill_multiplier = min(fill_multiplier, 1.0)
	energy = (max_energy - energy_reserved) * fill_multiplier
	print("Refilled energy: %s" % energy)
	emit_signal("energy_changed", energy, max_energy)

# Reduces energy by amount and emits energy_changed signal.
func use_energy(amount: float) -> void:
	energy -= amount
	emit_signal("energy_changed", energy, max_energy)

# Uses the module if it is an active-type module and there is enough energy
# for it. Uses up the needed energy.
# The InputEvent is passed for additional context information.
func use_module(module: Module, event: InputEvent) -> void:
	# Check if the module is active type (can actually be used).
	if module.module_type == Module.Type.Active:
		var energy_needed = module.energy_consumption
		if energy_needed <= energy:
			# Subtract the energy
			use_energy(energy_needed)
			# Actually use the module
			module.use(event)
		else:
			print("Not enough energy!")
	else:
		print("Tried to activate non-active module %s" % module.name)
