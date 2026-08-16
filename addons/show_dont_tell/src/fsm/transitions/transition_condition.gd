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
			var friendly_name := condition._get_friendly_name()
			if not friendly_name.is_empty():
				friendly_name = friendly_name.to_pascal_case()
				name = (prefix + friendly_name).validate_node_name()
			else:
				name = (prefix + condition.resource_name).validate_node_name()
		else:
			name = prefix + "[Unassigned]".validate_node_name()


func can_transition() -> bool:
	if condition and condition.tick_transition():
		return true
	if not condition:
		push_warning("TransitionCondition: No condition assigned for %s" % name)
	return _can_children_transition()


func _can_children_transition() -> bool:
	for child: Node in get_children():
		var child_condition := child as TransitionCondition
		if child_condition and child_condition.can_transition():
			return true
	return false


func handle_command(command: Command) -> bool:
	if not command or command.is_consumed():
		return false
	if condition and condition.handle_command(command):
		return true
	return _propagate_handle_command(command)


func _propagate_handle_command(command: Command) -> bool:
	for child in get_children():
		var child_condition := child as TransitionCondition
		if child_condition:
			if child_condition._propagate_handle_command(command):
				return true
	return false


func get_exit_node() -> FiniteState:
	for node: Node in get_children():
		if node is TransitionExit:
			return (node as TransitionExit).exit_node

		var transition := node as TransitionCondition
		if transition:
			var exit_node := transition._get_child_exit_node(transition)
			if exit_node:
				return exit_node

	push_warning("TransitionCondition: No exit node found for %s" % name)
	return null


func _get_child_exit_node(node: TransitionCondition) -> FiniteState:
	var child_condition := node as TransitionCondition
	# ! tick_transition could introduce side effects.
	if child_condition.tick_transition():
		var exit_node := child_condition._get_child_exit_node(node)
		if print_exit_transition:
			print(
				"Transition condition: ",
				child_condition.name,
				", exit node: ",
				exit_node.name if exit_node else &"null"
			)
		return exit_node
	return null


func _set_condition(new_condition: TransitionOnCondition) -> void:
	condition = new_condition
	if condition:
		condition.register_parent(self)
	_update_name()
	if condition and not condition.changed.is_connected(_update_name):
		condition.changed.connect(_update_name)


func _get_configuration_warnings() -> PackedStringArray:
	if not condition:
		return ["Condition is not assigned."]
	return []
