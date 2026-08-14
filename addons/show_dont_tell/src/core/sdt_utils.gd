class_name SdtUtils


## Retrieves a list of all registered classes that extend the given type.
static func get_class_list_of_type(type: GDScript) -> PackedStringArray:
	var class_map: Dictionary[String, ClassEntry] = _get_entry_script_list()
	var result: Array[String] = []
	for entry: ClassEntry in class_map.values():
		if entry.script_class == type.get_global_name():
			continue
		if _extends_type(entry.script_class, type, class_map):
			result.append(entry.script_class)
	result.sort()
	return PackedStringArray(result)


static func _get_entry_script_list() -> Dictionary[String, ClassEntry]:
	var global_classes := ProjectSettings.get_global_class_list()
	var class_entries: Dictionary[String, ClassEntry] = {}
	for entry: Dictionary in global_classes:
		var class_entry := ClassEntry.new(entry)
		if class_entry.script_class.is_empty():
			continue
		class_entries[class_entry.script_class] = class_entry
	return class_entries


static func _extends_type(
	start_class: String,
	type: GDScript,
	class_map: Dictionary[String, ClassEntry]
) -> bool:
	var current: String = start_class
	while not current.is_empty():
		if current == type.get_global_name():
			return true

		var entry: ClassEntry = class_map.get(current)
		if entry == null:
			return false
		current = entry.script_base

	return false


class ClassEntry:
	var script_class: String
	var script_base: String
	var icon_path: String
	var script_lang: String
	var project_path: String

	func _init(class_dict: Dictionary) -> void:
		script_class = class_dict.get("class", "")
		script_base = class_dict.get("base", "")
		icon_path = class_dict.get("icon", "")
		project_path = class_dict.get("path", "")
		script_lang = class_dict.get("language", "")
