class_name TransitionExample
extends TransitionRule

@export var enable_debug: bool = false

var last_command: Command
var last_command_time_ms: float
var command_timeout_ms: float = 500.0


func handle_command(command: Command) -> void:
	if command is CommandMove:
		last_command = command
		last_command_time_ms = Time.get_ticks_msec()
		if enable_debug:
			print("TransitionExample: Received CommandMove.")


func can_transition() -> bool:
	if last_command != null:
		if enable_debug:
			print("TransitionExample: Can transition.")
		return Time.get_ticks_msec() - last_command_time_ms < command_timeout_ms
	return false


func _on_transition(_state: FiniteState) -> void:
	last_command = null
	if enable_debug:
		print("TransitionExample: On transition event.")
