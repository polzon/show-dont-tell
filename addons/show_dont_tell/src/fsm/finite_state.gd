class_name FiniteState
extends BaseState
## Abstract base class for FiniteState nodes.

signal state_started
signal state_ended
## Emitted after [method change_state_node] has been called.
signal state_changed(new_state: FiniteState)

## The state logic that defines the behavior of this state.
@export var state_data: StateData:
	set = _set_state_data

@export_group("Debug")
@export var print_state_changes: bool = false

## The [StateMachine] that is handling the [FiniteState].
var state_machine: StateMachine:
	set = _set_state_machine


func _init() -> void:
	child_order_changed.connect(propagate_state_machine)


func _ready() -> void:
	_set_state_data(state_data)


## Propagated from the [StateMachine] while this is the current state.
func _handle_command(_command: Command) -> void:
	if state_data:
		state_data.handle_command(_command)


## Called when this node is made active by the [StateMachine].
func _on_state_start() -> void:
	if not state_data:
		if print_state_changes:
			push_error("FiniteState: No state data for state: %s" % name)
		state_started.emit()
		return

	state_data.state_start()
	if print_state_changes:
		print("FiniteState: Entering state: %s" % name)
	state_started.emit()


## Called when this node is being exited by the [StateMachine].
func _on_state_end() -> void:
	if not state_data:
		if print_state_changes:
			push_error("FiniteState: No state data for state: %s" % name)
		state_ended.emit()
		return

	state_data.exit_state()
	if print_state_changes:
		print("FiniteState: Exiting state: %s" % name)
	state_ended.emit()


## Similar to [member _physics_update], but only ticks when it's the
## current state.
func _physics_tick(delta: float) -> void:
	if state_data:
		state_data.physics_tick(delta)


## Similar to [member _process], but only ticks if it's the current state.
func _tick(delta: float) -> void:
	if state_data:
		state_data.process_tick(delta)
		_tick_transitions()


## Ticks all child [TransitionCondition] nodes and passes them to
## [member _tick_transition_condition].
func _tick_transitions() -> void:
	for child: Node in get_children():
		if child is TransitionCondition:
			var condition := child as TransitionCondition
			_tick_transition_condition(condition)


## Ticks and individual [TransitionCondition] node, checking if it can
## transition to a new state.
func _tick_transition_condition(condition: TransitionCondition) -> void:
	if not condition.can_transition():
		return

	var exit_node := condition.get_exit_node()
	if exit_node:
		if print_state_changes:
			print(
				(
					"FiniteState: Transitioning from %s to %s."
					% [name, exit_node.name]
				)
			)
		change_state_node(exit_node)


func propagate_state_machine() -> void:
	if state_data:
		state_data.state_machine = state_machine

	for child: Node in get_children():
		if child is FiniteState:
			(child as FiniteState).state_machine = state_machine


func _set_state_data(new_state_data: StateData) -> void:
	state_data = new_state_data
	if state_data:
		state_data.parent_state = self


func _set_state_machine(new_state_machine: StateMachine) -> void:
	state_machine = new_state_machine
	if state_data:
		state_data.state_machine = state_machine
		propagate_state_machine()


## Returns the active [FiniteState] the [StateMachine] is processing.
func current_state() -> FiniteState:
	if state_machine:
		return state_machine.state
	push_error("FiniteState: No state machine found for state: %s" % name)
	return null


func find_state_of_type(state_type: GDScript) -> FiniteState:
	if not state_machine:
		return
	return state_machine.get_child_state(state_type) as FiniteState


## Returns if this is the current state being processed by the [StateMachine].
func is_current_state() -> bool:
	return current_state() == self


## Request the [StateMachine] to change to [parameter new_state]. This parameter
## takes a [GDScript] object, assuming it's a script that inherits
## [FiniteState], otherwise it returns an error.
func change_state(new_state: GDScript) -> void:
	var state_node := find_state_of_type(new_state)
	change_state_node(state_node)


func change_state_node(state_node: FiniteState) -> void:
	if not state_machine or not state_node:
		return
	state_machine.change_state_node(state_node)
	state_changed.emit(state_node)
