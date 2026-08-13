@tool
class_name TransitionOnCommand
extends TransitionOnCondition
## Passes a transition check when an expected [Command] is passed to this.

# TODO: Move this _get _set command_list logic to a reusable util.

@export_group("Debug")
@export var enable_debug: bool = false

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


func _configuration_warning() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _command_script:
		warnings.append("Command type is empty.")
	elif not _is_command_script(_command_script):
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


func _get_property_list() -> Array[Dictionary]:
	var class_names := _collect_command_class_names()
	return [
		{
			"name": "command_type",
			"type": TYPE_STRING_NAME,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(class_names),
			"usage": PROPERTY_USAGE_DEFAULT,
		}
	]


func _set(property: StringName, value: Variant) -> bool:
	if property == &"command_type":
		_command_script = _to_command_script(value)
		return true
	return false


func _get(property: StringName) -> Variant:
	if property == &"command_type":
		if _command_script:
			return _command_script.get_global_name()
		return &""
	return null


func _to_command_script(value: Variant) -> GDScript:
	if value == null:
		return null
	if value is GDScript:
		return value
	if value is String or value is StringName:
		var script_name := StringName(str(value))
		if script_name.is_empty():
			return null
		return _resolve_script_by_name(script_name)
	return null


func _collect_command_class_names() -> PackedStringArray:
	var global_classes := ProjectSettings.get_global_class_list()
	var base_map: Dictionary = {}
	for entry: Dictionary in global_classes:
		var entry_class := str(entry["class"])
		var entry_base := str(entry["base"])
		base_map[entry_class] = entry_base
	var result: Array[String] = []
	for key: String in base_map:
		if key == "Command":
			continue
		if _extends_command(key, base_map):
			result.append(key)
	result.sort()
	return PackedStringArray(result)


func _extends_command(start_class: String, base_map: Dictionary) -> bool:
	var current: String = start_class
	while not current.is_empty():
		if current == "Command":
			return true
		current = str(base_map.get(current, ""))
	return false


func _resolve_script_by_name(script_name: StringName) -> GDScript:
	var global_classes := ProjectSettings.get_global_class_list()
	for entry in global_classes:
		if StringName(str(entry["class"])) == script_name:
			return load(str(entry["path"])) as GDScript
	return null
