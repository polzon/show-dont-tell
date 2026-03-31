class_name TestTransitionOnAction
extends GdUnitTestSuite
## Test the TransitionOnAction transition method.


func test_transition_export_property() -> void:
	var transition := TransitionOnAction.new()

	transition.transition_actions = ["move_left", "move_right"]

	assert_that(transition.transition_actions.size()).is_equal(2)
	assert_that("move_left" in transition.transition_actions).is_equal(true)
	transition.free()


func test_multiple_actions_property() -> void:
	var transition := TransitionOnAction.new()

	transition.transition_actions = ["action_a", "action_b", "action_c"]

	assert_that(transition.transition_actions.size()).is_equal(3)
	transition.free()


# Helper functions
func _create_state_machine() -> StateMachine:
	var sm := StateMachine.new()
	add_child(sm)

	var state_a := TestStateWithTransition.new()
	state_a.name = "StateWithTransition"
	sm.add_child(state_a)

	var exit_state := TestStateB.new()
	exit_state.name = "ExitState"
	sm.add_child(exit_state)

	var transition := TransitionOnAction.new()
	transition.name = "TransitionOnAction"
	transition.transition_actions = ["move_left"]
	transition.exit_node = exit_state
	state_a.add_child(transition)

	return sm


# Test classes
class TestStateWithTransition:
	extends FiniteState


class TestStateB:
	extends FiniteState
