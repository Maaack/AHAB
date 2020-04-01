extends PhysicalUnit


class_name PhysicalQuantityUnit


export(float) var quantity = 1.0 setget set_quantity
export(Resource) var physical_unit # TODO: remove after transitioning

func _to_string():
	return "[Quantity: [" + ._to_string() + ", " + str(quantity) + "]]"

func set_quantity(value:float):
	if value == null:
		return
	quantity = value
	if numerical_unit == NumericalUnitSetting.DISCRETE:
		quantity = floor(quantity)

func add_quantity(value:float):
	if value == null or value == 0.0:
		return
	set_quantity(quantity + value)

func split(value:float):
	if value == null:
		return
	var split_quantity = duplicate()
	value = min(value, quantity)
	add_quantity(-value)
	split_quantity.quantity = value
	return split_quantity

func get_physical_unit():
	var physical_unit = duplicate()
	physical_unit.quantity = 1.0
	return physical_unit

func add_physical_quantity(value:PhysicalQuantityUnit):
	if value == null:
		return
	if value.get_group_name() != get_group_name():
		print("Error: Adding incompatible quantities ", str(value), " and ", str(self))
		return
	add_quantity(value.quantity)	

func get_mass():
	return quantity * mass

func get_unit_mass():
	return mass

func get_unit_area():
	return .get_area()

func get_area():
	return quantity * .get_area()

#TODO: Remove redundant getters
func get_group_name():
	return group_name

func get_readable_name():
	return readable_name

func get_world_space_scene():
	print("FIX QuantityUnit: get_world_space_scene")
	return

func get_component_scene():
	print("FIX QuantityUnit: get_component_scene")
	return

func get_quantity_for_area(value:float):
	var unit_area = .get_area()
	return value / unit_area
