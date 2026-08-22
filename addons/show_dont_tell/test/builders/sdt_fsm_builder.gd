class_name SdtFsmBuilder
extends RefCounted

var _machine: StateMachine
var _state_count: int = 0


func _init() -> void:
	_machine = StateMachine.new()


## Creates a FiniteState of the given type, optionally attaching StateData,
## and adds it under the machine. Returns the created state.
func add_state(
	state_type: GDScript, state_data: StateData = null
) -> FiniteState:
	assert(
		_is_finite_state_script(state_type),
		"SdtFsmBuilder: %s is not a FiniteState subclass" % state_type
	)
	var state: FiniteState = state_type.new()
	_state_count += 1
	state.name = _state_name(state_type)
	if state_data:
		state.state_data = state_data
	_machine.add_child(state)
	return state


## Returns a unique name for the state, falling back to a counter when the
## script has no global class name.
func _state_name(state_type: GDScript) -> String:
	var global_name := state_type.get_global_name()
	if not global_name.is_empty():
		return global_name
	return "State%d" % _state_count


## Returns true if the script inherits from FiniteState.
func _is_finite_state_script(state_type: GDScript) -> bool:
	var script: Script = state_type
	while script:
		if script == FiniteState:
			return true
		script = script.get_base_script()
	return false


## Wires a TransitionCondition + TransitionExit under `from`, targeting `to`.
func add_transition(
	from: FiniteState, to: FiniteState, condition: TransitionOnCondition
) -> void:
	assert(condition, "SdtFsmBuilder: condition is null")
	var transition := TransitionCondition.new()
	transition.condition = condition
	var exit := TransitionExit.new()
	exit.exit_node = to
	transition.add_child(exit)
	from.add_child(transition)


## Returns the finished StateMachine.
func build() -> StateMachine:
	return _machine


## A toggleable condition that passes by default.
static func always_pass() -> ToggleableCondition:
	return _make_toggleable(true)


## A toggleable condition that fails by default.
static func always_fail() -> ToggleableCondition:
	return _make_toggleable(false)


static func _make_toggleable(passes: bool) -> ToggleableCondition:
	var condition := ToggleableCondition.new()
	condition.can = passes
	return condition


class ToggleableCondition:
	extends TransitionOnCondition

	var can: bool = true

	func _can_transition() -> bool:
		return can
