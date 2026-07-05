class_name TestStateMachine
extends GdUnitTestSuite
## Test the StateMachine class.


func test_state_getter_by_script() -> void:
	var sm := _create_state_machine()
	var state: FiniteState = sm.find_state_of_type(TestStateA)

	assert_that(state).is_not_null()
	assert_object(state).is_instanceof(TestStateA)


func test_state_setter() -> void:
	var sm := _create_state_machine()
	var state: FiniteState = sm.find_state_of_type(TestStateA)

	sm.state = state

	assert_that(sm.state).is_equal(state)


func test_state_change_emits_signals() -> void:
	var sm := _create_state_machine()
	var state_a: FiniteState = sm.find_state_of_type(TestStateA)
	var state_b: FiniteState = sm.find_state_of_type(TestStateB)
	sm.state = state_a

	# Changing state should emit both signals
	assert_signal(sm).is_emitted(sm.state_start)
	assert_signal(sm).is_emitted(sm.state_end)
	sm.state = state_b


func test_state_change_signal_order() -> void:
	var sm := _create_state_machine()
	var state_a: FiniteState = sm.find_state_of_type(TestStateA)
	var state_b: FiniteState = sm.find_state_of_type(TestStateB)
	sm.state = state_a

	# Verify both signals were emitted
	assert_signal(sm).is_emitted(sm.state_end)
	assert_signal(sm).is_emitted(sm.state_start)
	sm.state = state_b


func test_handle_command_forwards_to_state() -> void:
	var sm := _create_state_machine()
	var state: TestStateWithHandleCommand = sm.find_state_of_type(
		TestStateWithHandleCommand
	)
	sm.state = state
	var command := TestCommand.new()

	sm.handle_command(command)

	assert_bool(state.handle_command_called).is_equal(true)


func test_handle_command_when_disabled() -> void:
	var sm := _create_state_machine()
	var state: TestStateWithHandleCommand = sm.find_state_of_type(
		TestStateWithHandleCommand
	)
	sm.state = state
	sm.enabled = false
	var command := TestCommand.new()

	sm.handle_command(command)

	assert_bool(state.handle_command_called).is_equal(false)


func test_ready_with_no_state_warning() -> void:
	var sm: StateMachine = auto_free(StateMachine.new())
	add_child(sm)
	await await_idle_frame()

	assert_that(sm.is_inside_tree()).is_equal(true)
	assert_that(sm).is_not_null()
	assert_that(sm.state == null).is_equal(true)


func test_process_ticks_state() -> void:
	var sm := _create_state_machine()
	var state: TestStateWithTick = sm.find_state_of_type(TestStateWithTick)
	sm.state = state

	sm._process(0.016)

	assert_bool(state.tick_called).is_equal(true)


func test_physics_process_ticks_state() -> void:
	var sm := _create_state_machine()
	var state: TestStateWithPhysicsTick = sm.find_state_of_type(
		TestStateWithPhysicsTick
	)
	sm.state = state

	sm._physics_process(0.016)

	assert_bool(state.physics_tick_called).is_equal(true)


func _create_state_machine() -> StateMachine:
	var sm: StateMachine = auto_free(StateMachine.new())

	var state_a := TestStateA.new()
	state_a.name = "StateA"
	sm.add_child(state_a)

	var state_b := TestStateB.new()
	state_b.name = "StateB"
	sm.add_child(state_b)

	var state_with_tick := TestStateWithTick.new()
	state_with_tick.name = "StateWithTick"
	sm.add_child(state_with_tick)

	var state_with_physics := TestStateWithPhysicsTick.new()
	state_with_physics.name = "StateWithPhysicsTick"
	sm.add_child(state_with_physics)

	var state_with_action := TestStateWithHandleCommand.new()
	state_with_action.name = "StateWithHandleCommand"
	sm.add_child(state_with_action)

	add_child(sm)

	return sm


# Forward declare test state classes
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
