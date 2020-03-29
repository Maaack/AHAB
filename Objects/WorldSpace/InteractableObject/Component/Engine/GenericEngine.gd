extends "res://Objects/WorldSpace/InteractableObject/Node2D.gd"


const BASE_IMPULSE_VECTOR = Vector2(1, 0)
const BASE_ORIENTATION = -PI/2
const MASS_TO_IMPULSE_RATIO = 0.00001

export var max_engine_impulse = 1000.0
export(float, 0, 1) var minimum_throttle = 0.1
export(Resource) var fuel_requirement setget set_fuel_requirement
onready var engine_wake = $EngineWake

var is_triggered = false

func set_fuel_requirement(value:PhysicalCollection):
	if value == null:
		return 
	fuel_requirement = value.duplicate()

func trigger_on():
	is_triggered = true

func trigger_off():
	is_triggered = false

func integrate_forces(state):
	engine_wake.hide()
	if not is_triggered:
		return
	var fuels_required = get_fuel_requirement()
	if fuels_required == null:
		return
	var burned_fuel = burn_fuel()
	if burned_fuel == null:
		return
	var burned_ratio = burned_fuel.get_mass() / fuels_required.get_mass()
	if burned_ratio < minimum_throttle:
		return
	engine_wake.show()
	var physical_owner = get_physical_owner()
	var rotation_in_world_space = get_rotation_in_world_space()
	var total_engine_impulse = burned_ratio * max_engine_impulse
	var engine_impulse_vector = (BASE_IMPULSE_VECTOR * total_engine_impulse).rotated(rotation_in_world_space).rotated(BASE_ORIENTATION)
	var rotate_offset = physical_owner.get_rotation_in_world_space()
	var impulse_offset = get_position_in_ancestor(physical_owner).rotated(rotate_offset)
	physical_owner.apply_impulse(impulse_offset, engine_impulse_vector)
	trigger_off()

func get_mixed_ratio(fuels_available:PhysicalCollection, fuels_required:PhysicalCollection):
	var fuels_mixed = fuels_available.duplicate()
	var max_ratio = 1.0
	for fuel_required in fuels_required.physical_quantities:
		var key = fuel_required.get_group_name()
		if key == null:
			continue
		var fuel_available = fuels_available.get_physical_quantity(key)
		if fuel_available == null:
			max_ratio = 0.0
			break
		var available_ratio = fuel_available.quantity/fuel_required.quantity
		max_ratio = min(available_ratio, max_ratio)
	for fuel_mix in fuels_mixed.physical_quantities:
		fuel_mix.quantity *= max_ratio
	return fuels_mixed

func get_fuel_requirement():
	if fuel_requirement == null:
		return
	var physical_quantities = fuel_requirement.physical_quantities.duplicate()
	var engine_mass_ratio = max_engine_impulse * MASS_TO_IMPULSE_RATIO
	var resulting_fuel_requirements = PhysicalCollection.new()
	for physical_quantity in physical_quantities:
		var resulting_physical_quantity = physical_quantity.duplicate()
		var fuel_requirement = physical_quantity.quantity * engine_mass_ratio
		resulting_physical_quantity.quantity = fuel_requirement
		resulting_fuel_requirements.add_physical_quantity(resulting_physical_quantity)
	return resulting_fuel_requirements

func burn_fuel():
	var ship_contents = get_physical_owner().contents
	if ship_contents == null:
		return
	var fuels_required = get_fuel_requirement()
	if fuels_required == null:
		return
	var fuels_available = ship_contents.subtract_physical_quantities(fuels_required)
	var mixed_fuels = get_mixed_ratio(fuels_available, fuels_required)
	return mixed_fuels
