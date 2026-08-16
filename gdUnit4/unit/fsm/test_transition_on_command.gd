extends GdUnitTestSuite
## Verifies TransitionOnCommand matches an expected command, consumes it,
## and reports a transition exactly once before clearing the match flag.

## The "empty" warning message, kept here so the case body reads clearly.
const MESSAGE_EMPTY := "Command type is empty."


## A matching command is consumed and reported as a match.
func test_handle_command_matches_and_consumes() -> void:
	var condition := TransitionOnCommand.new()
	condition._command_script = TestCommand
	var command := TestCommand.new()

	var matched := condition.handle_command(command)

	assert_bool(matched).is_true()
	assert_bool(command.is_consumed()).is_true()


## A command of the wrong type is ignored and left unconsumed.
func test_handle_command_ignores_wrong_type() -> void:
	var condition := TransitionOnCommand.new()
	condition._command_script = TestCommand
	var command := OtherCommand.new()

	var matched := condition.handle_command(command)

	assert_bool(matched).is_false()
	assert_bool(command.is_consumed()).is_false()


## An already-consumed command is ignored so sibling conditions can still
## observe it.
func test_handle_command_ignores_consumed() -> void:
	var condition := TransitionOnCommand.new()
	condition._command_script = TestCommand
	var command := TestCommand.new()
	command.consume()

	var matched := condition.handle_command(command)

	assert_bool(matched).is_false()


## A match lets the transition fire once, then clears so the next tick
## does not re-fire.
func test_can_transition_true_after_match_then_clears() -> void:
	var condition := TransitionOnCommand.new()
	condition._command_script = TestCommand
	condition.handle_command(TestCommand.new())

	assert_bool(condition.tick_transition()).is_true()
	assert_bool(condition.tick_transition()).is_false()


## Without a match the transition never fires.
func test_can_transition_false_without_match() -> void:
	var condition := TransitionOnCommand.new()
	condition._command_script = TestCommand

	assert_bool(condition.tick_transition()).is_false()


class TestCommand:
	extends Command


class OtherCommand:
	extends Command


class TestNotACommand:
	extends RefCounted
