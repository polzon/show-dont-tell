class_name GdBuilderFsmState
extends RefCounted

var _root: FiniteState
var _nodes: Array[Node] = []:
	get = get_all_nodes


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_root.free()


func get_root() -> FiniteState:
	return _root


func get_all_nodes() -> Array[Node]:
	return _nodes


static func new_state(data_script: GDScript = null) -> GdBuilderFsmState:
	var new_builder := GdBuilderFsmState.new()
	var finite_state := FiniteState.new()
	if data_script:
		new_builder._set_state_data(finite_state, data_script)
	new_builder._root = finite_state
	new_builder._nodes = [finite_state]
	return new_builder


func _set_state_data(state_node: FiniteState, data_script: GDScript) -> void:
	if not data_script or not data_script.can_instantiate():
		return

	if state_node:
		var data_obj: Variant = data_script.new()
		if data_obj is StateData:
			state_node.state_data = data_obj
		elif data_obj is not RefCounted:
			data_obj.free()


func if_condition(condition_script: GDScript) -> GdBuilderFsmState:
	if (
		not condition_script
		or not condition_script.can_instantiate()
		or not _root
	):
		return self

	var condition_node := TransitionCondition.new()
	if condition_script:
		_set_condition_data(condition_node, condition_script)
	var last_node := _get_last_node()
	_add_node(last_node, condition_node)
	return self


func _set_condition_data(
	condition_node: TransitionCondition, data_script: GDScript
) -> void:
	if not data_script or not data_script.can_instantiate():
		return

	if condition_node:
		var data_obj: Variant = data_script.new()
		if data_obj is TransitionOnCondition:
			condition_node.condition = data_obj
		elif data_obj is not RefCounted:
			data_obj.free()


func exit_to(exit_node: Node) -> GdBuilderFsmState:
	var last_condition_node := _get_lastest_condition_node()
	assert(last_condition_node, "Failed to find condition node.")
	if not last_condition_node:
		return self

	assert(exit_node, "Exit node is invalid.")
	if last_condition_node and exit_node:
		var new_exit := TransitionExit.new()
		new_exit.exit_node = exit_node
		_add_node(last_condition_node, new_exit)
	return self


func _get_last_node() -> Node:
	if _nodes.is_empty():
		return null
	return _nodes[_nodes.size() - 1]


## Returns a duplicated array of [member _nodes] in reverse order, so we can
## find the last inserted node.
func _get_reverse_nodes() -> Array[Node]:
	var reverse_arr := _nodes.duplicate()
	reverse_arr.reverse()
	return reverse_arr


func _get_lastest_condition_node() -> TransitionCondition:
	for node: Node in _get_reverse_nodes():
		if node is TransitionCondition:
			return node
	push_error("Failed to find a TransitionCondition node!")
	return null


func _add_node(parent: Node, child: Node = null) -> void:
	assert(_nodes.has(parent), "Parent isn't added in the array!")
	assert(not _nodes.has(child))
	if child:
		parent.add_child(child)
		_nodes.push_back(child)
