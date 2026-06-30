@tool
@icon("uid://ck4toqx0nggiu")
class_name TransitionCondition
extends Node

const _PREFIX := "If_"
const _PREFIX_INVERTED := "IfNot_"

@export var condition: TransitionOnCondition:
	set = _set_condition

@export_group("Debug")
@export var print_exit_transition: bool = false


func _ready() -> void:
	_update_name()
	if Engine.is_editor_hint():
		return

	_set_condition(condition)
	if condition:
		condition.ready()


func _update_name() -> void:
	if (
		name == "TransitionCondition"
		or name.begins_with(_PREFIX)
		or name.begins_with(_PREFIX_INVERTED)
	):
		var prefix: String = (
			_PREFIX_INVERTED
			if condition and condition.invert_condition
			else _PREFIX
		)
		if condition:
			var friendly_name: String = condition._get_friendly_name()
			if friendly_name != "":
				friendly_name = friendly_name.to_pascal_case()
				name = (prefix + friendly_name).validate_node_name()
			else:
				name = (prefix + condition.resource_name).validate_node_name()
		else:
			name = prefix + "[Unassigned]".validate_node_name()


func can_transition() -> bool:
	if condition:
		return condition.tick_transition()
	push_warning("TransitionCondition: No condition assigned for %s" % name)
	return false


func get_exit_node() -> FiniteState:
	for child in get_children():
		if child is TransitionExit:
			var exit := child as TransitionExit
			return exit.exit_node

		if child is TransitionCondition:
			var child_condition := child as TransitionCondition
			if child_condition.tick_transition():
				if print_exit_transition:
					print(
						"Transition condition: ",
						child_condition.name,
						", exit node: ",
						child_condition.get_exit_node()
					)
				return child_condition.get_exit_node()

	push_warning("TransitionCondition: No exit node found for %s" % name)
	return null


func _set_condition(new_condition: TransitionOnCondition) -> void:
	condition = new_condition
	if condition and not Engine.is_editor_hint():
		condition.register_parent(self)
	_update_name()
	if (
		condition
		and not condition.changed.is_connected(_update_name)
		and not Engine.is_editor_hint()
	):
		condition.changed.connect(_update_name)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not condition:
		warnings.append("Condition is not assigned.")
	return warnings
