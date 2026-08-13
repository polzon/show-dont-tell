@tool
class_name TransitionOnCommand
extends TransitionOnCondition
## Passes a transition check when an expected [Command] is passed to this.

@export var command_type: GDScript

@export_group("Debug")
@export var enable_debug: bool = false

var _matched_command: bool = false


func handle_command(command: Command) -> bool:
	if not command or command.is_consumed():
		return false
	if not is_instance_of(command, command_type):
		return false
	_matched_command = true
	command.consume()
	if enable_debug:
		print("TransitionOnCommand: Received %s." % command_type)
	return true


func _can_transition() -> bool:
	if not _matched_command:
		return false
	_matched_command = false
	if enable_debug:
		print("TransitionOnCommand: Can transition.")
	return true


func _configuration_warning() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not command_type:
		warnings.append("Command type is empty.")
	elif not _is_command_script(command_type):
		warnings.append("Command type must extend Command.")
	return warnings


func _is_command_script(script: GDScript) -> bool:
	var current: Script = script
	while current:
		if current == Command:
			return true
		current = current.get_base_script()
	return false


func _get_friendly_name() -> String:
	return "CommandIsReceived"
