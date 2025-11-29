@tool
class_name OnActionTransition
extends StateTransition

@export var transition_actions: Array[StringName] = []:
	set(v):
		transition_actions = v
		update_configuration_warnings()


func _check_transition() -> bool:
	return false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	for action_str: StringName in transition_actions:
		if not InputMap.has_action(str(action_str)):
			warnings.push_back(action_str + " is an invalid action!")
	return warnings
