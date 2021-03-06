extends "res://Objects/WorldSpace/InteractableObject/Component/OutputSystem/CyclingOutputSystem.gd"


export(Resource) var custom_munition

func cycle_munition_loader():
	cycle_output_node()

func get_current_munition_loader():
	return get_current_output_node()

func trigger_on():
	var munition_loader = get_current_munition_loader()
	if munition_loader != null and munition_loader.has_method("set_next_munition"):
		munition_loader.set_next_munition(custom_munition)
		cycle_munition_loader()

