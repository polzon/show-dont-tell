@abstract
@icon("uid://qpdd6ue7x82h")
class_name BaseState
extends Node
## The origin node that all behavior derrives from.

# [Dev Note]
# This script is intended to be used as the base for both Behavior Tree and
# the State Machine. Including the state machines and states themselves.

static var debug_get_child_enabled: bool = false


func get_child_state(state_type: GDScript, internal: bool = false) -> BaseState:
	if debug_get_child_enabled:
		assert(
			_assert_get_child_state(state_type), "Finding inconsistent results!"
		)
	return _get_child_state_custom(state_type, internal)


func _get_child_state_custom(state_type: GDScript, internal: bool) -> Node:
	var children := get_children(internal)
	var index := children.find_custom(
		func(task: Node) -> bool: return is_instance_of(task, state_type)
	)
	return null if index < 0 else children[index]


func _get_child_state_loop(state_type: GDScript, internal: bool) -> Node:
	for node: Node in get_children(internal):
		var state_node := node as Node
		if is_instance_of(state_node, state_type):
			return state_node
	return null


func _get_child_state_find(state_type: GDScript, _internal: bool) -> Node:
	var results := find_children("", state_type.get_global_name(), false, true)
	return results.front() if not results.is_empty() else null


## Processed when the [BaseState] has been entered.
func _entered_state() -> void:
	pass


## Processed when the [BaseState] has exited.
func _exited_state() -> void:
	pass


## For debug purposes. Calls all the search child functions and ensures the
## results are the same for consistentcy.
func _assert_get_child_state(state_type: GDScript) -> bool:
	var filter_result := _get_child_state_custom(state_type, false)
	var loop_result := _get_child_state_loop(state_type, false)
	var find_result := _get_child_state_find(state_type, false)
	return filter_result == loop_result and loop_result == find_result
