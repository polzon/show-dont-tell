class_name MockCommand
extends Command

var last_command: Command

var was_performed: bool = false
var perform_count: int = 0


func handle_command(command: Command) -> void:
	last_command = command


func _execute() -> void:
	was_performed = true
	perform_count += 1
