@tool
class_name TransitionOnCommand
extends TransitionOnCondition
## Passes a transition check when an expected [Command] is passed to this.

const _COMMAND_PROPERTY: StringName = &"command_script"

@export_group("Debug")
@export var enable_debug: bool = false
@export_group("")

var _command_script: GDScript
var _matched_command: bool = false


func handle_command(command: Command) -> bool:
	if (
		not command
		or command.is_consumed()
		or not _command_script
		or not is_instance_of(command, _command_script)
	):
		return false
	_matched_command = true
	command.consume()
	if enable_debug:
		print("TransitionOnCommand: Received %s." % _command_script)
	return true


func _can_transition() -> bool:
	if not _matched_command:
		return false
	_matched_command = false
	if enable_debug:
		print("TransitionOnCommand: Can transition.")
	return true


func _get_friendly_name() -> String:
	return "CommandIsReceived"


func _get_property_list() -> Array[Dictionary]:
	var class_names := SdtUtils.get_class_list_of_type(Command)
	return [
		{
			"name": _COMMAND_PROPERTY,
			"type": TYPE_STRING_NAME,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(class_names),
			"usage": PROPERTY_USAGE_DEFAULT,
		}
	]


func _set(property: StringName, value: Variant) -> bool:
	if property == _COMMAND_PROPERTY:
		_command_script = SdtUtils.variant_to_script(value)
		return true
	return false


func _get(property: StringName) -> Variant:
	if property == _COMMAND_PROPERTY:
		if _command_script:
			return _command_script.get_global_name()
		return &""
	return null
