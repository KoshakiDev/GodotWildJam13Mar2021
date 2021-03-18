class_name ModuleManager
extends Node2D

# Emitted whenever the module energy changes.
signal energy_changed(energy, max_energy)
signal registered_module(module)
signal removed_module(module)
signal energy_depleted

# Maximum energy.
export var max_energy := 100

# weight of all the modules together.
var accumulated_weight: float
# Current energy.
var energy: float
# Currently reserved (unusable) energy.
var energy_reserved: float

# Dictionary keeping track of which input action is used for which module.
# Keys are the names of the actions (String), values are modules (ModuleContainer).
var use_mapping := {}

# Keeps track of all registered modules (ModuleContainer).
var modules := []

# Dictionary that tracks modules that are currently draining energy.
# Keys are the modules, values are the amounts which should be drained.
var draining_modules := {}

var main_module: ModuleContainer

var _player

onready var energy_refill_timer := $EnergyRefillTimer


func _unhandled_input(event: InputEvent):
	# Check if any of the use_mapping actions are pressed.
	for module_container in use_mapping:
		if event.is_action_pressed(use_mapping[module_container]):
			# Use the module associated with this action.
			use_module(module_container, event)

func _physics_process(delta):
	for module_container in modules:
		module_container.world_module.module.physics_process(delta)

func _process(delta):
	for module_container in draining_modules:
		# Use the energy that should be drained per second (therefor * delta).
		# Don't start the refill timer so the player instantly refills energy
		# when touching terrain.
		use_energy(draining_modules[module_container] * delta, false)
		# Calculate the energy that will be drained in the next half second.
		var energy_drain = module_container.energy_consumption / 2
		# If that energy drain is bigger than the current energy, toggle the
		# module off.
		if energy_drain > energy:
			module_container.world_module.module.toggle(false)
			draining_modules.erase(module_container)


# Sets up the ModuleManager for use. Needs to be called after the player is ready.
func setup(player) -> void:
	_player = player
	
	var head = ModuleContainer.new(load("res://Source/Modules/Head/PlayerHead.tscn").instance())
	
	# Sets the main module to be the head, so it can not be removed.
	main_module = head
	
	# Register the modules.
	register_module(head)
	
	# Refill energy initially.
	refill_energy()

# Registers a module to add its weight, reserved energy and add it's input action.
# Automatically subtracts those values when the module is freed (see _on_module_removed)
func register_module(module: ModuleContainer, input_action := "") -> void:
	if module in modules:
		print("Tried to register already registered module in ModuleManager.gd")
		return
	
	# Setup the connections in the module
	module.world_module.setup(_player)
	add_child(module.world_module.module)
	
	modules.append(module)
	
	if input_action != "":
		use_mapping[module] = input_action
	accumulated_weight += module.weight
	energy_reserved += module.energy_reserved
	emit_signal("registered_module", module)

# Is called whenever a module is removed. Changes weight, reserved energy and use_mapping
# to not include that module anymore.
func remove_module(module: ModuleContainer) -> void:
	# Remove the actual module from the world.
	remove_child(module.world_module.module)
	# Stop tracking the module container.
	modules.erase(module)
	
	if use_mapping.has(module):
		use_mapping.erase(module)
	accumulated_weight -= module.world_module.module.weight
	energy_reserved -= module.world_module.module.energy_reserved
	emit_signal("removed_module", module)

# Refills the energy to the full (or to a percentile of the full energy based on
# fill_multiplier) fill_multiplier is capped at 1.0.
func refill_energy(fill_multiplier := 1.0) -> void:
	# Only refill the energy, if the refill cooldown has run out.
	# TODO: move to call of refill_energy().
	if energy_refill_timer.is_stopped():
		fill_multiplier = min(fill_multiplier, 1.0)
		energy = (max_energy - energy_reserved) * fill_multiplier
		emit_signal("energy_changed", energy, max_energy)

# Reduces energy by amount and emits energy_changed signal.
func use_energy(amount: float, start_refill_cooldown := true) -> void:
	energy -= amount
	if start_refill_cooldown:
		energy_refill_timer.start(.2)
	emit_signal("energy_changed", energy, max_energy)

# Uses the module if it is an active-type module and there is enough energy
# for it. Uses up the needed energy.
# The InputEvent is passed for additional context information.
func use_module(module_container: ModuleContainer, event: InputEvent) -> void:
	# Check if the module is active type (can actually be used).
	if module_container.module_type == Module.Type.Active:
		var energy_needed = module_container.energy_consumption
		if energy_needed <= energy:
			# Subtract the energy
			use_energy(energy_needed)
			# Actually use the module
			module_container.world_module.use(event)
		else:
			emit_signal("energy_depleted")
			print("Not enough energy!")
	elif module_container.module_type == Module.Type.Toggled:
		if module_container in draining_modules:
			# If the module is on, turn it off and remove it from the draining modules.
			module_container.world_module.module.toggle(false)
			draining_modules.erase(module_container)
		else:
			# You need to have enough energy to sustain the module for one second.
			var energy_needed = module_container.energy_consumption
			if energy_needed <= energy:
				# Toggle the module on.
				module_container.world_module.module.toggle(true)
				# Add it to the draining modules.
				draining_modules[module_container] = energy_needed
	else:
		print("Tried to activate non-active module.")
