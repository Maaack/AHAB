extends VBoxContainer


const EMPTY_GROUP_NAME = 'EMPTY'

onready var grid_node = $GridContainer
onready var empty_value_node = $Header/EmptyValue

var button_scene = preload("res://Objects/Interface/Button/Button.tscn")
var physical_collection setget set_physical_collection
var empty_quantity setget set_empty_quantity

func set_physical_collection(value:PhysicalCollection):
	if value == null:
		return
	physical_collection = value
	update_inventory()

func set_empty_quantity(value:PhysicalQuantity):
	if value == null:
		return
	empty_quantity = value
	empty_value_node.text = str(value.quantity) + " M^2"

func update_inventory():
	clear_inventory()
	if physical_collection == null:
		return
	for physical_quantity in physical_collection.physical_quantities:
		if physical_quantity.group_name == EMPTY_GROUP_NAME:
			set_empty_quantity(physical_quantity)
			continue
		var button_instance = button_scene.instance()
		grid_node.add_child(button_instance)
		button_instance.physical_unit = physical_quantity
		
func clear_inventory():
	for child in grid_node.get_children():
		child.queue_free()
