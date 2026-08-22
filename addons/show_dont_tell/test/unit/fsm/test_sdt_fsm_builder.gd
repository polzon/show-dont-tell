extends GdUnitTestSuite
## Tests the SdtFsmBuilder.

var _builder: SdtFsmBuilder


func before_test() -> void:
	_builder = SdtFsmBuilder.new()


## add_state creates a FiniteState of the requested type and returns it.
func test_add_state_returns_state() -> void:
	var state := _builder.add_state(TestStateA)
	auto_free(_builder.build())

	assert_object(state).is_not_null()
	assert_object(state).is_instanceof(TestStateA)


## add_state attaches the given StateData to the created state.
func test_add_state_attaches_data() -> void:
	var data := TestStateData.new()

	var state := _builder.add_state(TestStateA, data)
	auto_free(_builder.build())

	assert_object(state.state_data).is_same(data)


## add_state without data leaves the state's data null.
func test_add_state_without_data() -> void:
	var state := _builder.add_state(TestStateA)
	auto_free(_builder.build())

	assert_object(state.state_data).is_null()


## add_transition wires a condition and exit under the from state, targeting
## the to state.
func test_add_transition_wires_exit() -> void:
	var from := _builder.add_state(TestStateA)
	var to := _builder.add_state(TestStateB)

	_builder.add_transition(from, to, SdtFsmBuilder.always_pass())

	var machine := _builder.build()
	add_child(machine)

	var transition := from.get_child(0) as TransitionCondition
	assert_object(transition.get_exit_node()).is_same(to)


## build returns a StateMachine containing the added states.
func test_build_returns_machine_with_states() -> void:
	_builder.add_state(TestStateA)
	_builder.add_state(TestStateB)

	var machine := _builder.build()
	add_child(machine)

	assert_object(machine).is_instanceof(StateMachine)
	assert_object(machine.find_state_of_type(TestStateA)).is_not_null()
	assert_object(machine.find_state_of_type(TestStateB)).is_not_null()


## always_pass returns a condition that passes by default.
func test_always_pass_passes() -> void:
	var condition := SdtFsmBuilder.always_pass()
	auto_free(_builder.build())

	assert_bool(condition.tick_transition()).is_true()


## always_fail returns a condition that fails by default.
func test_always_fail_fails() -> void:
	var condition := SdtFsmBuilder.always_fail()
	auto_free(_builder.build())

	assert_bool(condition.tick_transition()).is_false()


## The toggleable condition can be flipped at runtime.
func test_condition_is_toggleable() -> void:
	var condition := SdtFsmBuilder.always_pass()
	auto_free(_builder.build())
	condition.can = false

	assert_bool(condition.tick_transition()).is_false()


class TestStateA:
	extends FiniteState


class TestStateB:
	extends FiniteState


class TestStateData:
	extends StateData
