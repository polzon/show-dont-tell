class_name TestBaseState
extends GdUnitTestSuite
## Test the BaseState class, which serves as the foundation for both
## FSM States and BT BaseTasks.


func test_started_signal_emitted_on_enter() -> void:
	var state := _create_test_state()

	assert_signal(state).is_emitted("started")
	state._entered_state()


func test_ended_signal_emitted_on_exit() -> void:
	var state := _create_test_state()

	assert_signal(state).is_emitted("ended")
	state._exited_state()


func test_process_on_active_default_false() -> void:
	var state := _create_test_state()

	assert_bool(state.process_on_active).is_false()


func test_process_on_active_setter() -> void:
	var state := _create_test_state()
	state.process_on_active = true

	assert_bool(state.process_on_active).is_true()


func test_entered_and_exited_signals() -> void:
	var state := _create_test_state()

	assert_signal(state).is_emitted("started")
	state._entered_state()

	assert_signal(state).is_emitted("ended")
	state._exited_state()


func test_signal_emit_count() -> void:
	var state := _create_test_state()

	assert_signal(state).is_emitted("started")
	state._entered_state()

	assert_signal(state).is_emitted("started")
	state._entered_state()


# Helper functions
func _create_test_state() -> BaseState:
	var state := ConcreteTestState.new()
	add_child(state)
	return state


# Concrete test state class (BaseState is abstract)
class ConcreteTestState:
	extends BaseState
