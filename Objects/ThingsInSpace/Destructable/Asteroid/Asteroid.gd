extends "res://Objects/ThingsInSpace/Destructable/Destructable.gd"


func destroy_self():
	if can_destroy():
		world_space.asteroid_counter -= 1
		.destroy_self()

func set_physical_unit(value:PhysicalUnit):
	if value == null:
		return
	sprite.modulate = value.color
	.set_physical_unit(value)

func exit_physics_area():
	if not destroyed:
		world_space.put_in_orbit(get_physical_unit())
		destroy_self()
