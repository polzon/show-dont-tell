class_name TestStateMachine
extends GdUnitTestSuite
## Test the StateMachine class.

const DELTA := 0.016

const FORWARD_CASES: Array[Array] = [
	# [enabled, command_forwards]
	[true, true],
	[false, false],
]

var _sm: StateMachine


func before_test() -> void:
	_sm = auto_free(StateMachine.new())

	var state_a := TestStateA.new()
	state_a.name = "StateA"
	_sm.add_child(state_a)

	var state_b := TestStateB.new()
	state_b.name = "StateB"
	_sm.add_child(state_b)

	var state_with_tick := TestStateWithTick.new()
	state_with_tick.name = "StateWithTick"
	_sm.add_child(state_with_tick)

	var state_with_physics := TestStateWithPhysicsTick.new()
	state_with_physics.name = "StateWithPhysicsTick"
	_sm.add_child(state_with_physics)

	var state_with_action := TestStateWithHandleCommand.new()
	state_with_action.name = "StateWithHandleCommand"
	_sm.add_child(state_with_action)

	add_child(_sm)


func test_state_getter_by_script() -> void:
	var state := _sm.find_state_of_type(TestStateA)

	assert_object(state).is_not_null()
	assert_object(state).is_instanceof(TestStateA)


func test_state_setter() -> void:
	var state := _sm.find_state_of_type(TestStateA)

	_sm.state = state

	assert_that(_sm.state).is_equal(state)


func test_state_change_emits_signals() -> void:
	var state_a := _sm.find_state_of_type(TestStateA)
	var state_b := _sm.find_state_of_type(TestStateB)
	_sm.state = state_a

	assert_signal(_sm).is_emitted(_sm.state_start)
	assert_signal(_sm).is_emitted(_sm.state_end)
	_sm.state = state_b


## handle_command reaches the active state only while the machine is
## enabled; disabling must swallow the command.
func test_handle_command_case(
	enabled: bool,
	forwards: bool,
	_test_parameters := FORWARD_CASES,
) -> void:
	var state: TestStateWithHandleCommand = _sm.find_state_of_type(
		TestStateWithHandleCommand
	)
	_sm.state = state
	_sm.enabled = enabled

	_sm.handle_command(TestCommand.new())

	assert_bool(state.handle_command_called).is_equal(forwards)


func test_ready_with_no_state() -> void:
	var bare_sm: StateMachine = auto_free(StateMachine.new())
	add_child(bare_sm)
	await await_idle_frame()

	assert_that(bare_sm.is_inside_tree()).is_true()
	assert_that(bare_sm.state).is_null()


## _process drives the active state's tick with whatever delta the engine
## supplies; the delta value itself should not gate the call.
func test_process_ticks_state(
	fuzzer_delta := Fuzzers.rangef(0.0, 1.0),
	_fuzzer_iterations := 10,
) -> void:
	var state: TestStateWithTick = _sm.find_state_of_type(TestStateWithTick)
	_sm.state = state

	_sm._process(fuzzer_delta.next_value())

	assert_bool(state.tick_called).is_true()


func test_physics_process_ticks_state() -> void:
	var state: TestStateWithPhysicsTick = _sm.find_state_of_type(
		TestStateWithPhysicsTick
	)
	_sm.state = state

	_sm._physics_process(DELTA)

	assert_bool(state.physics_tick_called).is_true()


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
