extends GdUnitTestSuite
## Verifies TransitionOnCommand matches an expected command, consumes it,
## and reports a transition exactly once before clearing the match flag.

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


## A matching command is consumed and reported as a match.
func test_handle_command_matches_and_consumes() -> void:
	var condition := TransitionOnCommand.new()
	condition.command_type = TestCommand
	var command := TestCommand.new()

	var matched := condition.handle_command(command)

	assert_bool(matched).is_true()
	assert_bool(command.is_consumed()).is_true()


## A command of the wrong type is ignored and left unconsumed.
func test_handle_command_ignores_wrong_type() -> void:
	var condition := TransitionOnCommand.new()
	condition.command_type = TestCommand
	var command := OtherCommand.new()

	var matched := condition.handle_command(command)

	assert_bool(matched).is_false()
	assert_bool(command.is_consumed()).is_false()


## An already-consumed command is ignored so sibling conditions can still
## observe it.
func test_handle_command_ignores_consumed() -> void:
	var condition := TransitionOnCommand.new()
	condition.command_type = TestCommand
	var command := TestCommand.new()
	command.consume()

	var matched := condition.handle_command(command)

	assert_bool(matched).is_false()


## A match lets the transition fire once, then clears so the next tick
## does not re-fire.
func test_can_transition_true_after_match_then_clears() -> void:
	var condition := TransitionOnCommand.new()
	condition.command_type = TestCommand
	condition.handle_command(TestCommand.new())

	assert_bool(condition.tick_transition()).is_true()
	assert_bool(condition.tick_transition()).is_false()


## Without a match the transition never fires.
func test_can_transition_false_without_match() -> void:
	var condition := TransitionOnCommand.new()
	condition.command_type = TestCommand

	assert_bool(condition.tick_transition()).is_false()


class TestCommand:
	extends Command


class OtherCommand:
	extends Command


class TestNotACommand:
	extends RefCounted
