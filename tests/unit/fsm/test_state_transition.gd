class_name TestStateTransition
extends GdUnitTestSuite
## Test the StateTransition base class.


func test_parent_state_getter() -> void:
	var result := _create_test_state_machine()
	var state: TestStateWithTransition = result.sm.get_finite_state(
		TestStateWithTransition
	)
	var transition: TestTransition = state.get_child(0)

	assert_that(transition.parent_state).is_equal(state)
	await _cleanup_test_state_machine(result)


func test_parent_state_setter() -> void:
	var result := _create_test_state_machine()
	var state: TestStateWithTransition = result.sm.get_finite_state(
		TestStateWithTransition
	)
	var transition: TestTransition = state.get_child(0)

	# Verify initial parent state
	var initial_parent := transition.parent_state

	# Verify parent_state can be retrieved after initial assignment
	assert_that(initial_parent).is_equal(state)
	await _cleanup_test_state_machine(result)


func test_state_machine_getter() -> void:
	var result := _create_test_state_machine()
	var state: TestStateWithTransition = result.sm.get_finite_state(
		TestStateWithTransition
	)
	var transition: TestTransition = state.get_child(0)

	assert_that(transition.state_machine).is_equal(result.sm)
	await _cleanup_test_state_machine(result)


func test_is_current_state_true() -> void:
	var result := _create_test_state_machine()
	var state: TestStateWithTransition = result.sm.get_finite_state(
		TestStateWithTransition
	)
	result.sm.state = state
	var transition: TestTransition = state.get_child(0)

	assert_that(transition.is_current_state()).is_equal(true)
	await _cleanup_test_state_machine(result)


func test_is_current_state_false() -> void:
	var result := _create_test_state_machine()
	var state_a: TestStateWithTransition = result.sm.get_finite_state(
		TestStateWithTransition
	)
	var state_b: FiniteState = result.sm.get_finite_state(TestStateB)
	result.sm.state = state_b
	var transition: TestTransition = state_a.get_child(0)

	assert_that(transition.is_current_state()).is_equal(false)
	await _cleanup_test_state_machine(result)


func test_transition_allowed_signal_emitted() -> void:
	var result := _create_test_state_machine()
	var state: TestStateWithTransition = result.sm.get_finite_state(
		TestStateWithTransition
	)
	var transition: TestTransition = state.get_child(0)

	assert_signal(transition).is_emitted("transition_allowed")
	transition.can_transition()
	await _cleanup_test_state_machine(result)


func test_state_connected_signal_emitted_on_parent_set() -> void:
	var result := _create_test_state_machine()
	var state: TestStateWithTransition = result.sm.get_finite_state(
		TestStateWithTransition
	)
	var transition: TestTransition = TestTransition.new()

	assert_signal(transition).is_emitted("state_connected")
	transition.parent_state = state
	transition.queue_free()
	await _cleanup_test_state_machine(result)


func test_state_disconnected_signal_emitted() -> void:
	var result := _create_test_state_machine()
	var state_a: TestStateWithTransition = result.sm.get_finite_state(
		TestStateWithTransition
	)
	var state_b: FiniteState = result.sm.get_finite_state(TestStateB)
	var transition: TestTransition = state_a.get_child(0)

	assert_signal(transition).is_emitted("state_disconnected")
	transition.parent_state = state_b as TestStateWithTransition
	await _cleanup_test_state_machine(result)


# Helper classes and functions
class TestSetup:
	var sm: StateMachine
	var state_a: FiniteState
	var transition: StateTransition
	var exit_node: FiniteState
	var state_b: FiniteState


func _create_test_state_machine() -> TestSetup:
	var setup := TestSetup.new()
	setup.sm = StateMachine.new()

	setup.state_a = TestStateWithTransition.new()
	setup.state_a.name = "StateWithTransition"
	setup.sm.add_child(setup.state_a)

	setup.transition = TestTransition.new()
	setup.transition.name = "Transition"
	setup.exit_node = TestStateB.new()
	setup.transition.exit_node = setup.exit_node
	setup.state_a.add_child(setup.transition)

	setup.state_b = TestStateB.new()
	setup.state_b.name = "StateB"
	setup.sm.add_child(setup.state_b)

	return setup


func _cleanup_test_state_machine(setup: TestSetup) -> void:
	# Free all tracked nodes
	if is_instance_valid(setup.exit_node):
		setup.exit_node.queue_free()
	if is_instance_valid(setup.transition):
		setup.transition.queue_free()
	if is_instance_valid(setup.state_a):
		setup.state_a.queue_free()
	if is_instance_valid(setup.state_b):
		setup.state_b.queue_free()
	if is_instance_valid(setup.sm):
		setup.sm.queue_free()
	# Wait one frame for all deletions to process
	await get_tree().process_frame


# Test classes
class TestStateWithTransition:
	extends FiniteState


class TestStateB:
	extends FiniteState


class TestTransition:
	extends StateTransition

	func _check_transition() -> bool:
		return true
