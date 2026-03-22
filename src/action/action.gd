@abstract class_name Action
extends RefCounted
## Command pattern for handling advanced input actions.


func perform() -> void:
	pass


func get_name() -> StringName:
	const FALLBACK_NAME := &"<Invalid>"
	var script: Script = get_script()
	if script:
		return script.get_global_name()
	return FALLBACK_NAME
