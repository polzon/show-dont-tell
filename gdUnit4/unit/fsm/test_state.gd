class_name TestState
extends GdUnitTestSuite
## Test the FiniteState class.

const DELTA := 0.016

const CURRENT_CASES: Array[Array] = [
	# [state_is_machine_current, expected]
	[true, true],
	[false, false],
]

var _state_machine: StateMachine
var _state_a: FiniteState
var _state_b: FiniteState
var _state_with_tick: TestStateWithTick
var _state_with_physics: TestStateWithPhysicsTick
var _state_with_action: TestStateWithHandleCommand


func before_test() -> void:
	_state_machine = auto_free(StateMachine.new())
	add_child(_state_machine)

	_state_a = _create_state(TestStateA, &"StateA")
	_state_b = _create_state(TestStateB, &"StateB")
	_state_with_tick = _create_state(TestStateWithTick, &"StateWithTick")
	_state_with_physics = _create_state(
		TestStateWithPhysicsTick, &"StateWithPhysicsTick"
	)
	_state_with_action = _create_state(
		TestStateWithHandleCommand, &"StateWithHandleCommand"
	)


## is_current_state reflects whether the state is the machine's active
## state, for both the current and a sibling state.
func test_is_current_state_case(
	current_is_selected: bool,
	expected: bool,
	_test_parameters := CURRENT_CASES,
) -> void:
	var state: FiniteState = _state_a if current_is_selected else _state_b
	_state_machine.state = _state_a

	assert_bool(state.is_current_state()).is_equal(expected)


func test_state_machine_getter() -> void:
	_state_machine.state = _state_a

	assert_that(_state_a.state_machine).is_equal(_state_machine)


func test_current_state_returns_state() -> void:
	_state_machine.state = _state_a

	assert_that(_state_a.current_state()).is_equal(_state_a)


func test_tick_called_when_current() -> void:
	_state_machine.state = _state_with_tick

	_state_with_tick._tick(DELTA)

	assert_bool(_state_with_tick.tick_called).is_true()


func test_physics_tick_called_when_current() -> void:
	_state_machine.state = _state_with_physics

	_state_with_physics._physics_tick(DELTA)

	assert_bool(_state_with_physics.physics_tick_called).is_true()


func test_handle_command_called() -> void:
	_state_machine.state = _state_with_action

	_state_with_action._handle_command(TestCommand.new())

	assert_bool(_state_with_action.handle_command_called).is_true()


func test_transition_calls_after_transition() -> void:
	var transition: TransitionCondition = mock(TransitionCondition)
	do_return(true).on(transition).can_transition()
	do_return(_state_b).on(transition).get_exit_node()
	_state_a.state_machine = _state_machine
	_state_machine.enabled = true
	_state_machine.state = _state_a

	_state_a._tick_transition_condition(transition)

	verify(transition, 1).after_transition()


func _create_state(state_type: GDScript, state_name: StringName) -> FiniteState:
	var new_state: FiniteState = state_type.new()
	var state: FiniteState = auto_free(new_state)
	state.name = state_name
	_state_machine.add_child(state)
	return state


class TestStateA:
	extends FiniteState


class TestStateB:
	extends FiniteState


class TestStateWithTick:
	extends FiniteState

	var tick_called: bool = false

	func _tick(_delta: float) -> void:
		tick_called = true


class TestStateWithPhysicsTick:
	extends FiniteState

	var physics_tick_called: bool = false

	func _physics_tick(_delta: float) -> void:
		physics_tick_called = true


class TestStateWithHandleCommand:
	extends FiniteState

	var handle_command_called: bool = false

	func _handle_command(_command: Command) -> void:
		handle_command_called = true


class TestCommand:
	extends Command
