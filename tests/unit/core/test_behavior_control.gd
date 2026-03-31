class_name TestBehaviorControl
extends GdUnitTestSuite
## Test the BaseState class, which serves as the abstract base for
## StateMachine and BehaviorTree.
## Tests the enabled property which is implemented in StateMachine
## and BehaviorTree.


func test_enabled_default_true() -> void:
	var control := _create_test_control()

	assert_that(control.enabled).is_equal(true)


func test_enabled_toggle_via_setter() -> void:
	var control := _create_test_control()
	control.enabled = false

	assert_that(control.enabled).is_equal(false)

	control.enabled = true

	assert_that(control.enabled).is_equal(true)


func test_enabled_toggled_signal_emitted() -> void:
	var control := _create_test_control()

	assert_signal(control).is_emitted("enabled_toggled")
	control.enabled = false


func test_enabled_toggled_signal_emit_count() -> void:
	var control := _create_test_control()

	assert_signal(control).is_emitted("enabled_toggled")
	control.enabled = false

	assert_signal(control).is_emitted("enabled_toggled")
	control.enabled = true

	assert_signal(control).is_emitted("enabled_toggled")
	control.enabled = false


func test_process_mode_disabled_when_enabled_false() -> void:
	var control := _create_test_control()
	control.enabled = true
	# Trigger the initial process mode setup
	await get_tree().process_frame
	var initial_mode := control.process_mode

	control.enabled = false

	assert_that(control.process_mode).is_equal(Node.PROCESS_MODE_DISABLED)

	control.enabled = true

	assert_that(control.process_mode).is_equal(initial_mode)


# Helper functions
func _create_test_control() -> StateMachine:
	var control := StateMachine.new()
	var test_state := SimpleTestState.new()
	control.add_child(test_state)
	add_child(control)
	return control


# Simple test state for StateMachine
class SimpleTestState:
	extends FiniteState

	func _init() -> void:
		pass
