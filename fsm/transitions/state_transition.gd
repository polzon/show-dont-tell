@abstract
class_name StateTransition
extends Node
## Defined transition to migrate to a new state.

signal transition_allowed

## The state this transaction node is connected to.
var state: State:
	get = _get_state

## The state machine that [member state] is attached to.
var state_machine: StateMachine:
	get = _get_statemachine

## The node this node will transition to if the requirements are met.
@export var exit_node: State


func can_transition() -> void:
	var result := _check_transition()
	if result:
		transition_allowed.emit(result)


@abstract func _check_transition() -> bool


func _get_state() -> State:
	if not state and get_parent() is State:
		state = get_parent()
	return state


func _get_statemachine() -> StateMachine:
	if not state_machine and state and state.state_machine:
		state_machine = state.state_machine
	return state_machine
