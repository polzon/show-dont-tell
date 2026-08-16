class_name SdtUtils


## Retrieves a list of all registered classes that extend the given type.
static func get_class_list_of_type(
	type: GDScript, include_abstract: bool = false
) -> PackedStringArray:
	var class_map := _get_entry_script_list(include_abstract)
	var result: PackedStringArray = []
	for entry: ClassEntry in class_map.values():
		if entry.script_class == type.get_global_name():
			continue
		if _extends_type(entry.script_class, type, class_map):
			result.append(entry.script_class)
	result.sort()
	return result


static func _get_entry_script_list(
	include_abstract: bool = false
) -> Dictionary[StringName, ClassEntry]:
	var global_classes := ProjectSettings.get_global_class_list()
	var class_entries: Dictionary[StringName, ClassEntry] = {}
	for entry: Dictionary in global_classes:
		var class_entry := ClassEntry.new(entry)
		if (
			class_entry.script_class.is_empty()
			or (class_entry.is_abstract() and not include_abstract)
		):
			continue
		class_entries[class_entry.script_class] = class_entry
	return class_entries


static func _extends_type(
	start_class: StringName,
	type: GDScript,
	class_map: Dictionary[StringName, ClassEntry]
) -> bool:
	var current: StringName = start_class
	while not current.is_empty():
		if current == type.get_global_name():
			return true

		var entry: ClassEntry = class_map.get(current)
		if entry == null:
			return false
		current = entry.script_base

	return false


static func variant_to_script(value: Variant) -> GDScript:
	if value == null:
		return null
	if value is GDScript:
		return value
	if value is String or value is StringName:
		var script_name: StringName = value
		if not script_name.is_empty():
			return get_script_by_name(script_name)
	return null


static func get_script_by_name(script_name: StringName) -> GDScript:
	var global_classes := ProjectSettings.get_global_class_list()
	for entry: Dictionary in global_classes:
		if entry.get("class", &"") == script_name:
			var script_path: String = entry.get("path", "")
			if not script_path.is_empty():
				return load(script_path) as GDScript
	return null


class ClassEntry:
	var script_class: String = ""
	var script_base: String = ""
	var icon_path: String = ""
	var script_lang: String = ""
	var project_path: String = ""

	func _init(class_dict: Dictionary) -> void:
		script_class = class_dict.get("class", "")
		script_base = class_dict.get("base", "")
		icon_path = class_dict.get("icon", "")
		project_path = class_dict.get("path", "")
		script_lang = class_dict.get("language", "")

	func is_abstract() -> bool:
		if not script_class.is_empty():
			return false
		var script: GDScript = load(script_class)
		return script.is_abstract() if script else false
