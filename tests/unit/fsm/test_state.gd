class_name TestState
extends GdUnitTestSuite
## Test the State class.


func test_state_machine_getter() -> void:
	var state_machine := _create_state_machine()
	var state: FiniteState = state_machine.get_finite_state(TestStateA)
	state_machine.state = state

	assert_that(state.state_machine).is_equal(state_machine)


func test_is_current_state_true() -> void:
	var state_machine := _create_state_machine()
	var state: FiniteState = state_machine.get_finite_state(TestStateA)
	state_machine.state = state

	assert_that(state.is_current_state()).is_equal(true)


func test_is_current_state_false() -> void:
	var state_machine := _create_state_machine()
	var state_a: FiniteState = state_machine.get_finite_state(TestStateA)
	var state_b: FiniteState = state_machine.get_finite_state(TestStateB)
	state_machine.state = state_a

	assert_that(state_b.is_current_state()).is_equal(false)


func test_current_state_returns_state() -> void:
	var state_machine := _create_state_machine()
	var state_a: FiniteState = state_machine.get_finite_state(TestStateA)
	state_machine.state = state_a

	assert_that(state_a.current_state()).is_equal(state_a)


func test_tick_called_when_current() -> void:
	var state_machine := _create_state_machine()
	var state: TestStateWithTick = state_machine.get_finite_state(
		TestStateWithTick
	)
	state_machine.state = state

	state._tick(0.016)

	assert_that(state.tick_called).is_equal(true)


func test_physics_tick_called_when_current() -> void:
	var state_machine := _create_state_machine()
	var state: TestStateWithPhysicsTick = state_machine.get_finite_state(
		TestStateWithPhysicsTick
	)
	state_machine.state = state

	state._physics_tick(0.016)

	assert_that(state.physics_tick_called).is_equal(true)


func test_handle_action_called() -> void:
	var state_machine := _create_state_machine()
	var state: TestStateWithHandleCommand = state_machine.get_finite_state(
		TestStateWithHandleCommand
	)
	state_machine.state = state
	var command: TestCommand = TestCommand.new()

	state._handle_action(command)

	assert_that(state.handle_action_called).is_equal(true)


# Helper functions
func _create_state_machine() -> StateMachine:
	var sm := StateMachine.new()
	add_child(sm)

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

	return sm


# Test state classes
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

	var handle_action_called: bool = false

	func _handle_action(_command: Command) -> void:
		handle_action_called = true


class TestCommand:
	extends ActorCommand

	func _init() -> void:
		super._init(null)
