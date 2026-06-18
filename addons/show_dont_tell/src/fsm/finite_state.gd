class_name FiniteState
extends BaseState
## Abstract base class for FiniteState nodes.

@export var state_data: StateData

## The [StateMachine] that is handling the [FiniteState].
var state_machine: StateMachine:
	get = get_state_machine


func _ready() -> void:
	if state_data:
		state_data.register_state(self)


## Called from [StateMachine] when an command is passed to it,
## but only when it's the [member current_state].
func _handle_command(_command: Command) -> void:
	pass


## Emitted when this [FiniteState] node is made active.
func _on_state_start() -> void:
	if state_data:
		state_data._on_state_start()


## Emitted right before the current [FiniteState] is about to be replaced with
## a new state. This will deactivate the [FiniteState] node, not free it.
func _on_state_end() -> void:
	if state_data:
		state_data._on_state_end()


## Similar to [member _physics_update], but only runs when the state instance is class
## the current state.
func _physics_tick(delta: float) -> void:
	if state_data:
		state_data._physics_tick(delta)


## Similar to [member _process], but only runs when the state is
##  the current state.
func _tick(delta: float) -> void:
	if state_data:
		state_data._process_tick(delta)


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
		state_machine = _recursively_find_state_machine(get_parent())
	return state_machine


func _recursively_find_state_machine(node: Node) -> StateMachine:
	if node is StateMachine:
		return node
	if node.get_parent():
		return _recursively_find_state_machine(node.get_parent())
	return null
