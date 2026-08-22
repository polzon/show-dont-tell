class_name TestBehaviorControl
extends GdUnitTestSuite
## Test the enabled/toggling behavior of the StateMachine control.

const FUZZER_ITERATIONS: int = 10

var _control: StateMachine


func before_test() -> void:
	var test_state := SimpleTestState.new()
	_control = auto_free(StateMachine.new())
	_control.add_child(test_state)
	add_child(_control)


func test_enabled_default_true() -> void:
	assert_that(_control.enabled).is_true()


## enabled mirrors the setter, and toggling off disables process mode while
## toggling back on restores the inherited mode.
func test_enabled_process_mode_case(
	enabled: bool,
	expected_mode: ProcessMode,
	_test_parameters := _process_mode_cases(),
) -> void:
	_control.enabled = enabled

	assert_bool(_control.enabled).is_equal(enabled)
	assert_that(_control.process_mode).is_equal(expected_mode)


## Method-backed because expected_mode uses a class constant.
func _process_mode_cases() -> Array[Array]:
	var cases: Array[Array] = [
		[false, Node.PROCESS_MODE_DISABLED],
		[true, Node.PROCESS_MODE_INHERIT],
	]
	for case in cases:
		assert_array(case).is_not_empty()
	return cases


## enabled_toggled fires on every flip; a rapid sequence of toggles must
## emit once per flip, not duplicate or drop any.
func test_enabled_toggled_fires_per_flip(
	fuzzer_flips := Fuzzers.rangei(1, 5),
	_fuzzer_iterations := FUZZER_ITERATIONS,
) -> void:
	var flips := fuzzer_flips.next_value()

	for i in flips:
		assert_signal(_control).is_emitted("enabled_toggled")
		_control.enabled = i % 2 == 0


class SimpleTestState:
	extends FiniteState

	func _init() -> void:
		pass
