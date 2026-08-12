@tool
class_name MockTransitionOnCommand
extends TransitionOnCondition

var last_command: Command


func handle_command(command: Command) -> bool:
	if command:
		last_command = command
		command.consume()
		return true
	return false


func _can_transition() -> bool:
	return false
