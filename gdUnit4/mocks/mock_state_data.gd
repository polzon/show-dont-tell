class_name MockStateData
extends StateData

var last_command: Command


func handle_command(command: Command) -> void:
	last_command = command
