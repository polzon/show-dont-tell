extends GdUnitTestSuite
## Verifies TransitionOnCommand._configuration_warning() validates that
## command_type is a Command subclass.

## The "empty" warning message, kept here so the case body reads clearly.
const MESSAGE_EMPTY := "Command type is empty."


## The configuration warning reports a missing or non-Command command_type
## and stays silent for a valid Command subclass.
func test_configuration_warning_case(
	command_type: GDScript,
	expects_warning: bool,
	_test_parameters := _warning_cases(),
) -> void:
	var condition := TransitionOnCommand.new()
	condition.command_type = command_type

	var warnings := condition._configuration_warning()

	if expects_warning:
		var message := (
			MESSAGE_EMPTY
			if command_type == null
			else "Command type must extend Command."
		)
		assert_array(warnings).contains([message])
	else:
		assert_array(warnings).is_empty()


## Method-backed because class references are not constant expressions.
func _warning_cases() -> Array[Array]:
	var cases: Array[Array] = [
		[null, true],
		[TestCommand, false],
		[TestNotACommand, true],
	]
	for case in cases:
		assert_array(case).is_not_empty()
	return cases


class TestCommand:
	extends Command


class TestNotACommand:
	extends RefCounted
