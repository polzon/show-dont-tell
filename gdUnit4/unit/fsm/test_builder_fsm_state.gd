extends GdUnitTestSuite
## Unit tests for GdBuilderFsmState.


## Rows: [data_script, expects_state_data]. Method-backed because class
## references are not constant expressions.
func _state_data_cases() -> Array[Array]:
	var cases: Array[Array] = [
		[TestStateData, true],
		[null, false],
		[FiniteState, false],
	]
	for case in cases:
		assert_array(case).is_not_empty()
	return cases


## new_state attaches a StateData only when given a script that instantiates
## into a StateData; invalid or mismatched scripts leave it null.
func test_state_creation_case(
	data_script: GDScript,
	expects_state_data: bool,
	_test_parameters := _state_data_cases(),
) -> void:
	var builder := GdBuilderFsmState.new_state(data_script)
	var root: FiniteState = auto_free(builder.get_root())
	add_child(root)

	assert_object(root).is_not_null()
	if expects_state_data:
		assert_object(root.state_data).is_not_null()
	else:
		assert_object(root.state_data).is_null()


func test_add_condition_valid() -> void:
	var builder := GdBuilderFsmState.new_state(TestStateData).if_condition(
		TransitionOnCommand
	)
	var root: FiniteState = auto_free(builder.get_root())
	add_child(root)

	assert_object(root).is_not_null()
	assert_int(root.get_child_count()).is_equal(1)
	var condition_node := root.get_child(0) as TransitionCondition
	assert_object(condition_node).is_not_null()
	assert_object(condition_node.condition).is_not_null()


## A built chain of state, condition and exit produces one node of each type
## after an exit is attached to a condition.
func test_create_condition_exit() -> void:
	var first_builder := GdBuilderFsmState.new_state(TestStateData)
	var first_root: FiniteState = auto_free(first_builder.get_root())
	add_child(first_root)

	var second_builder := (
		GdBuilderFsmState
		. new_state(TestStateData)
		. if_condition(TransitionOnCommand)
		. exit_to(first_root)
	)
	var second_root: FiniteState = auto_free(second_builder.get_root())
	add_child(second_root)

	var nodes := second_builder.get_all_nodes()
	assert_array(nodes).is_not_empty()
	assert_array(nodes).has_size(3)

	assert_int(_count_by_type(nodes, FiniteState)).is_equal(1)
	assert_int(_count_by_type(nodes, TransitionCondition)).is_equal(1)
	assert_int(_count_by_type(nodes, TransitionExit)).is_equal(1)


func _count_by_type(nodes: Array, node_type: GDScript) -> int:
	return (
		nodes
		. filter(func(v: Variant) -> bool: return is_instance_of(v, node_type))
		. size()
	)


class TestStateData:
	extends StateData
