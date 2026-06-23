@tool
@icon("uid://b2c5d20doh4sp")
class_name TransitionExit
extends Node

## The [FiniteState] to transition to when exiting the current state.
@export var exit_node: FiniteState:
	set(v):
		exit_node = v
		_update_name()


func _ready() -> void:
	_update_name()


func _update_name() -> void:
	if name == "TransitionExit" or name.begins_with("To_"):
		if exit_node:
			name = ("To_" + exit_node.name).validate_node_name()
		else:
			name = "To_[Unassigned]".validate_node_name()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not exit_node:
		warnings.append("Exit node is not assigned.")
	return warnings
