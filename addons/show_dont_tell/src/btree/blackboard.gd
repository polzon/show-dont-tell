@icon("res://addons/show_not_tell/icons/blackboard.svg")
class_name BT_Blackboard
extends Node
## The Blackboard is a useful object in Behavior Trees, designed to store and
## share data between multiple nodes. It enables efficient communication and
## data access among nodes, ensuring consistent behavior across your game
## characters or objects.
##
## @tutorial(Beehave Reference): https://bitbra.in/beehave/#/manual/blackboard

var data: Dictionary[StringName, Variant] = {}

@onready var behavior_tree: BehaviorTree = _find_behavior_tree()


func _find_behavior_tree(parent: Node = self) -> BehaviorTree:
	if parent is BehaviorTree:
		return parent
	if parent.get_parent():
		return _find_behavior_tree(parent.get_parent())
	return null


func set_data(key: StringName, value: Variant) -> void:
	data[key] = value


func get_data(key: StringName) -> Variant:
	return data.get(key, null)
