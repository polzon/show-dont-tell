@abstract class_name Command
extends RefCounted
## Command pattern for handling advanced input actions.

var consumed: bool = false


func consume() -> void:
	consumed = true


func is_consumed() -> bool:
	return consumed


func perform() -> void:
	pass


func get_name() -> StringName:
	const FALLBACK_NAME := &"<Invalid>"
	var script: Script = get_script()
	if script:
		return script.get_global_name()
	return FALLBACK_NAME
