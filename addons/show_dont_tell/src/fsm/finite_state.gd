class_name FiniteState
extends BaseState
## Base finite state node that processes inner [StateData] logic.
## [br]
## This class is *not* meant to be extended. Instead, create a [StateData]
## resource and assign it to the [member state_data] property. This design
## allows separating the "how" from the "what" of the state behavior.

signal state_started
signal state_ended
## Emitted after [method change_state_node] has been called.
signal state_changed(new_state: FiniteState)

enum TickMode { PROCESS, PHYSICS }

## The state logic that defines the behavior of this state.
@export var state_data: StateData:
	set = _set_state_data

@export_group("Debug")
@export var print_state_changes: bool = false
## If this state should tick the transition checks on [method _process] or
## on [method _physics_process].
@export var tick_mode := TickMode.PHYSICS

## The [StateMachine] that is handling the [FiniteState].
var state_machine: StateMachine:
	set = _set_state_machine


func _init() -> void:
	child_order_changed.connect(_propagate_state_machine)


func _ready() -> void:
	_set_state_data(state_data)
	if state_data:
		state_data.ready()


## Propagated from the [StateMachine] while this is the current state.
func _handle_command(_command: Command) -> void:
	if not _command or _command.is_consumed():
		return

	for child: Node in get_children():
		var child_condition := child as TransitionCondition
		if child_condition:
			if child_condition.handle_command(_command):
				return

	if state_data:
		state_data.handle_command(_command)


## Called when this node is made active by the [StateMachine].
func _on_state_start() -> void:
	if not state_data:
		state_started.emit()

	else:
		state_data.state_start()
		if print_state_changes:
			print("FiniteState: Entering state: %s" % name)
		state_started.emit()


## Called when this node is being exited by the [StateMachine].
func _on_state_end() -> void:
	if not state_data:
		state_ended.emit()

	else:
		state_data.state_end()
		if print_state_changes:
			print("FiniteState: Exiting state: %s" % name)
		state_ended.emit()


## Similar to [member _physics_update], but only ticks when it's the
## current state.
func physics_tick(delta: float) -> void:
	if state_data:
		state_data.physics_tick(delta)

	for child: Node in get_children():
		var child_condition := child as TransitionCondition
		if child_condition:
			child_condition.physics_tick(delta)

	if tick_mode == TickMode.PHYSICS:
		_tick_transitions()


## Similar to [member _process], but only ticks if it's the current state.
func process_tick(delta: float) -> void:
	if state_data:
		state_data.process_tick(delta)

	for child: Node in get_children():
		var child_condition := child as TransitionCondition
		if child_condition:
			child_condition.process_tick(delta)

	if tick_mode == TickMode.PROCESS:
		_tick_transitions()


## Ticks all child [TransitionCondition] nodes and passes them to
## [member _tick_transition_condition].
func _tick_transitions() -> void:
	for child: Node in get_children():
		var child_condition := child as TransitionCondition
		if child_condition:
			_tick_transition_condition(child_condition)


## Ticks and individual [TransitionCondition] node, checking if it can
## transition to a new state.
func _tick_transition_condition(condition: TransitionCondition) -> void:
	if not condition.can_transition():
		return
	var exit_node := condition.get_exit_node()
	if not exit_node:
		return

	if print_state_changes:
		print(
			"FiniteState: ",
			"Transitioning from %s to %s." % [name, exit_node.name]
		)
	if state_machine and state_machine.enabled:
		condition.before_transition()
		state_machine.change_state_node(exit_node)
		condition.after_transition()
	else:
		state_machine.change_state_node(exit_node)


func _propagate_state_machine() -> void:
	for child: Node in get_children():
		var child_state := child as FiniteState
		if child_state:
			child_state.state_machine = state_machine


func _set_state_data(new_state_data: StateData) -> void:
	state_data = new_state_data
	if state_data:
		state_data.parent_state = self


func _set_state_machine(new_state_machine: StateMachine) -> void:
	state_machine = new_state_machine
	if state_data:
		state_data.state_machine = state_machine
		_propagate_state_machine()


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


func _get_configuration_warnings() -> PackedStringArray:
	if not state_data:
		return ["FiniteState: No state data assigned to state: %s" % name]
	return []
