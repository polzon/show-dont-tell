class_name GdBuilderFsmState
extends RefCounted

var _root: FiniteState


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_root.free()


func build() -> FiniteState:
	return _root


func create_state(data_script: GDScript = null) -> GdBuilderFsmState:
	_root = FiniteState.new()
	if data_script:
		_set_state_data(_root, data_script)
	return self


func _set_state_data(state: FiniteState, data_script: GDScript) -> void:
	if not data_script or not data_script.can_instantiate():
		return

	if state:
		var data_obj: Variant = data_script.new()
		if data_obj is StateData:
			state.state_data = data_obj
		elif data_obj is not RefCounted:
			data_obj.free()


func create_condition(condition_script: GDScript) -> GdBuilderFsmState:
	if (
		not condition_script
		or not condition_script.can_instantiate()
		or not _root
	):
		return self

	var condition_node := TransitionCondition.new()
	if condition_script:
		_set_condition_data(condition_node, condition_script)
	var deepest_node := _get_deepest_node(_root)
	deepest_node.add_child(condition_node)
	return self


func _set_condition_data(
	condition: TransitionCondition, data_script: GDScript
) -> void:
	if not data_script or not data_script.can_instantiate():
		return

	if condition:
		var data_obj: Variant = data_script.new()
		if data_obj is TransitionOnCondition:
			condition.condition = data_obj
		elif data_obj is not RefCounted:
			data_obj.free()


func _get_deepest_node(node: Node) -> Node:
	if node.get_child_count() == 0:
		return node
	return _get_deepest_node(node.get_child(0))
