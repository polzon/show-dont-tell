@abstract class_name StateTransition
extends Node
## Defined transition to migrate to a new state.

signal transition_allowed

signal state_connected(new_state: State)
signal state_disconnected(old_state: State)

## The node this node will transition to if the requirements are met.
@export var exit_node: State

## The state this transaction node is connected to.
var parent_state: State:
	set = _set_state,
	get = _get_state
## The state machine that [member state] is attached to.
var state_machine: StateMachine:
	get = _get_statemachine

var _checked_parent_state: bool = false


func can_transition() -> void:
	var result := _check_transition()
	if result:
		transition_allowed.emit(result)


@abstract func _check_transition() -> bool


func is_current_state() -> bool:
	if parent_state:
		return parent_state.is_current_state()
	return false


func _get_state() -> State:
	if not parent_state and not _checked_parent_state and get_parent() is State:
		_checked_parent_state = true
		parent_state = get_parent()
	return parent_state


func _set_state(new_state: State) -> void:
	if parent_state:
		state_disconnected.emit(parent_state)
	parent_state = new_state
	_checked_parent_state = false
	state_connected.emit(parent_state)


func _get_statemachine() -> StateMachine:
	if not state_machine and parent_state and parent_state.state_machine:
		state_machine = parent_state.state_machine
	return state_machine


func set_input_as_handled() -> void:
	var viewport := get_viewport()
	if viewport:
		viewport.set_input_as_handled()
