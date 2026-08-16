@tool
class_name MockTransitionOnCommand
extends TransitionOnCondition

var last_command: Command
var process_tick_called: bool = false
var physics_tick_called: bool = false


func handle_command(command: Command) -> bool:
	if command:
		last_command = command
		command.consume()
		return true
	return false


func _can_transition() -> bool:
	return false


func _process_tick(_delta: float) -> void:
	process_tick_called = true


func _physics_tick(_delta: float) -> void:
	physics_tick_called = true
