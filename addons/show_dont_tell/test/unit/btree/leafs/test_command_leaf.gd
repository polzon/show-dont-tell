class_name TestCommandLeaf
extends GdUnitTestSuite
## Test the BT_CommandLeaf (executes an action).


## Method-backed because class references are not constant expressions.
func _base_type_cases() -> Array[Array]:
	var cases: Array[Array] = [
		[BT_LeafTask],
		[BehaviorTask],
	]
	for case in cases:
		assert_array(case).is_not_empty()
	return cases


func test_command_leaf_is_a_task_type(
	base_type: GDScript, _test_parameters := _base_type_cases()
) -> void:
	var leaf: Node = auto_free(ConcreteCommandLeaf.new())

	assert_object(leaf).is_instanceof(base_type)


class ConcreteCommandLeaf:
	extends BT_CommandLeaf

	func _tick(_delta: float) -> Status:
		return SUCCESS
