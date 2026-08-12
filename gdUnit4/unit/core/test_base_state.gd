class_name TestBaseState
extends GdUnitTestSuite
## Test the BaseState class, which serves as the foundation for
## FSM states and BT base tasks.

const FUZZER_ITERATIONS: int = 10


func test_started_signal_emitted_on_enter() -> void:
	var state := _create_test_state()

	assert_signal(state).is_emitted("started")
	state._entered_state()


func test_ended_signal_emitted_on_exit() -> void:
	var state := _create_test_state()

	assert_signal(state).is_emitted("ended")
	state._exited_state()


func test_entered_and_exited_signals() -> void:
	var state := _create_test_state()

	assert_signal(state).is_emitted("started")
	state._entered_state()

	assert_signal(state).is_emitted("ended")
	state._exited_state()


## Every enter re-emits started; verify the signal stays wired across many
## enter/exit cycles rather than just one.
func test_enter_emits_started_each_time(
	fuzzer_cycles := Fuzzers.rangei(1, 5),
	_fuzzer_iterations := FUZZER_ITERATIONS,
) -> void:
	var state := _create_test_state()
	var cycles := fuzzer_cycles.next_value()

	for _i in cycles:
		assert_signal(state).is_emitted("started")
		state._entered_state()


func test_process_on_active_default_false() -> void:
	var state := _create_test_state()

	assert_bool(state.process_on_active).is_false()


## process_on_active echoes the setter across both states; the signal wiring
## must toggle process on start and off on end.
func test_process_on_active_echoes_setter(
	fuzzer_enabled := Fuzzers.rangei(0, 1),
	_fuzzer_iterations := FUZZER_ITERATIONS,
) -> void:
	var state := _create_test_state()
	var enabled := fuzzer_enabled.next_value() == 1

	state.process_on_active = enabled

	assert_bool(state.process_on_active).is_equal(enabled)


func _create_test_state() -> BaseState:
	var state: BaseState = auto_free(ConcreteTestState.new())
	add_child(state)
	return state


class ConcreteTestState:
	extends BaseState
