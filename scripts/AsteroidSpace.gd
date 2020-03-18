extends "res://scripts/WorldSpace/Node2D.gd"


onready var gravity_space = $Area2D
onready var gravity_space_collider = $Area2D/CollisionShape2D
onready var planet = $Planet8
onready var planet_collider = $Planet8/CollisionShape2D
onready var world_space = get_world_space()

export var asteroid_spawn_distance_from_surface = 1000.0
export var asteroid_spawn_distance_from_edge = 1000.0
export var asteroid_spawn_delay = 5
export var asteroid_spawn_max = 300
export var time_since_last_spawn = 1000.0
enum OrbitDirectionSetting{CLOCKWISE, COUNTER_CLOCKWISE, EITHER}
export(OrbitDirectionSetting) var orbit_direction
export var orbit_force_mod = 40.0

var asteroid_preload = preload("res://objects/Asteroid.tscn")
var asteroid_counter = 0

func get_space_radius():
	return gravity_space_collider.shape.radius

func get_planet_radius():
	return planet_collider.shape.radius

func get_random_orbit_radius():
	var min_spawn_radius = get_planet_radius() + asteroid_spawn_distance_from_surface
	var max_spawn_radius = get_space_radius() - asteroid_spawn_distance_from_edge
	return rand_range(min_spawn_radius, max_spawn_radius)

func get_random_orbit_position():
	var random_rotation = rand_range(0, PI*2)
	var direction = Vector2(1,0).rotated(random_rotation)
	var random_radius = get_random_orbit_radius()

	return direction * random_radius

func get_random_orbit_position_in_world_space():
	return get_position_in_world_space() + get_random_orbit_position()

func get_orbital_velocity(start_position:Vector2):
	if orbit_direction == OrbitDirectionSetting.EITHER:
		var orbit_directions = [OrbitDirectionSetting.CLOCKWISE, OrbitDirectionSetting.COUNTER_CLOCKWISE]
		orbit_directions.shuffle()
		orbit_direction = orbit_directions.pop_front()
	var orbit_vector = null
	if orbit_direction == OrbitDirectionSetting.CLOCKWISE:
		orbit_vector = Vector2(0,-1)
	elif orbit_direction == OrbitDirectionSetting.COUNTER_CLOCKWISE:
		orbit_vector = Vector2(0,1)
	else:
		print('Error: Not a valid orbit direction!')
	var angle = get_angle_to(start_position)
	orbit_vector = orbit_vector.rotated(get_angle_to(start_position))
	var orbit_force = gravity_space.get_gravity()
	return orbit_vector * orbit_force * orbit_force_mod

func _process(delta):
	time_since_last_spawn += delta
	if asteroid_counter < asteroid_spawn_max:
		if time_since_last_spawn >= asteroid_spawn_delay:
			time_since_last_spawn -= asteroid_spawn_delay
			var instance = asteroid_preload.instance()
			world_space.add_child(instance)
			var start_position = get_random_orbit_position_in_world_space()
			instance.set_position(start_position)
			instance.set_axis_velocity(get_orbital_velocity(start_position))
			asteroid_counter += 1
