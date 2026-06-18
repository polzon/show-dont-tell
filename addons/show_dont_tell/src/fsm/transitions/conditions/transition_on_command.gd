@tool
class_name TransitionOnCommand
extends TransitionOnCondition

@export var command_type: StringName
@export var command_timeout_ms: float = 500.0

@export var enable_debug: bool = false

var last_command: Command
var last_command_time_ms: float


func handle_command(command: Command) -> void:
	if is_instance_of(command, command_type):
		last_command = command
		last_command_time_ms = Time.get_ticks_msec()
		if enable_debug:
			print("TransitionOnCommand: Received %s." % command_type)


func can_transition() -> bool:
	if last_command != null:
		if enable_debug:
			print("TransitionOnCommand: Can transition.")
		return Time.get_ticks_msec() - last_command_time_ms < command_timeout_ms
	return false


func _on_transition(_state: FiniteState) -> void:
	last_command = null
	if enable_debug:
		print("TransitionOnCommand: On transition event.")


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	if command_type != "":
		properties.append(
			{
				"name": "command_type",
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": command_type,
				"usage": PROPERTY_USAGE_EDITOR or PROPERTY_USAGE_READ_ONLY
			}
		)
	return properties


func _configuration_warning() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if command_type == "":
		warnings.append("Command type is empty.")
	return warnings
