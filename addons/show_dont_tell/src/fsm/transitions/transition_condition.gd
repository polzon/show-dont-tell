@tool
@icon("uid://ck4toqx0nggiu")
class_name TransitionCondition
extends Node

const _PREFIX := "If_"

@export var condition: TransitionOnCondition:
	set(v):
		condition = v
		_update_name()
		if condition and not condition.changed.is_connected(_update_name):
			condition.changed.connect(_update_name)


func _ready() -> void:
	_update_name()


func _update_name() -> void:
	if name == "TransitionCondition" or name.begins_with(_PREFIX):
		if condition:
			var friendly_name: String = condition._get_friendly_name()
			if friendly_name != "":
				friendly_name = friendly_name.to_pascal_case()
				name = (_PREFIX + friendly_name).validate_node_name()
			else:
				name = (_PREFIX + condition.resource_name).validate_node_name()
		else:
			name = _PREFIX + "[Unassigned]".validate_node_name()


func can_transition() -> bool:
	if condition:
		return condition.can_transition()
	return true


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not condition:
		warnings.append("Condition is not assigned.")
	return warnings
