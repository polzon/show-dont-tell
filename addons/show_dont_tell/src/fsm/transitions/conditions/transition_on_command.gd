@tool
class_name TransitionOnCommand
extends TransitionOnCondition
## Passes a transition check when an expected [Command] is passed to this.

@export var command_type: GDScript
@export var command_timeout_ms: float = 500.0

@export_group("Debug")
@export var enable_debug: bool = false

var last_command: Command
var last_command_time_ms: float


func handle_command(command: Command) -> bool:
	if is_instance_of(command, command_type):
		last_command = command
		last_command_time_ms = Time.get_ticks_msec()
		command.consume()
		if enable_debug:
			print("TransitionOnCommand: Received %s." % command_type)
		return true
	return false


func _can_transition() -> bool:
	if last_command != null:
		if enable_debug:
			print("TransitionOnCommand: Can transition.")
		return Time.get_ticks_msec() - last_command_time_ms < command_timeout_ms
	return false


func _on_transition(_state: FiniteState) -> void:
	last_command = null
	if enable_debug:
		print("TransitionOnCommand: On transition event.")


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
