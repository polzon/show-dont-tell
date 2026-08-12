extends GdUnitTestSuite
## Verifies TransitionOnCommand._configuration_warning() correctly validates
## that command_type is a Command subclass.


func test_warning_when_command_type_empty() -> void:
	var condition := TransitionOnCommand.new()

	var warnings := condition._configuration_warning()

	assert_array(warnings).contains(["Command type is empty."])


func test_no_warning_when_command_type_is_command_subclass() -> void:
	var condition := TransitionOnCommand.new()
	condition.command_type = TestCommand

	var warnings := condition._configuration_warning()

	assert_array(warnings).is_empty()


func test_warning_when_command_type_is_not_command_subclass() -> void:
	var condition := TransitionOnCommand.new()
	condition.command_type = TestNotACommand

	var warnings := condition._configuration_warning()

	assert_array(warnings).contains(["Command type must extend Command."])


class TestCommand:
	extends Command


class TestNotACommand:
	extends RefCounted
