@abstract class_name FiniteState
extends BaseState
## Abstract base class for FiniteState nodes.

## The [StateMachine] that is handling the [FiniteState].
@onready var state_machine: StateMachine:
	get = get_state_machine


## Called from [StateMachine] when an action is passed to it,
## but only when it's the [member current_state].
func _handle_action(_action: Action) -> void:
	pass


## Emitted when this [FiniteState] node is made active.
func _on_state_start() -> void:
	return


## Emitted right before the current [FiniteState] is about to be replaced with
## a new state. This will deactivate the [FiniteState] node, not free it.
func _on_state_end() -> void:
	return


## Similar to [member _physics_update], but only runs when the state is
## the current state.
func _physics_tick(_delta: float) -> void:
	pass


## Similar to [member _process], but only runs when the state is
##  the current state.
func _tick(_delta: float) -> void:
	pass


## Returns the active [FiniteState] the [StateMachine] is processing.
func current_state() -> FiniteState:
	if state_machine:
		return state_machine.state
	return null


func get_finite_state(state_type: GDScript) -> FiniteState:
	# TODO: Need to clarify that this is checking the state_machine,
	# and not the calling node.
	if state_machine:
		return state_machine.get_child_state(state_type) as FiniteState
	return null


## Returns a [bool] if this state is the current state being processed by the
## [StateMachine].
func is_current_state() -> bool:
	return current_state() == self


## Request the [StateMachine] to change to [parameter new_state]. This parameter
## takes a [GDScript] object, assuming it's a script that inherits
## [FiniteState], otherwise it returns an error.
func change_state(new_state: GDScript) -> void:
	var state_node := get_finite_state(new_state)
	change_state_node(state_node)


func change_state_node(state_node: FiniteState) -> void:
	if state_machine and state_node:
		state_machine.change_state_node(state_node)


func get_state_machine() -> StateMachine:
	if not state_machine:
		state_machine = get_parent() as StateMachine
	return state_machine
