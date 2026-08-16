class_name TestConditionLeaf
extends GdUnitTestSuite
## Test the BT_ConditionLeaf (evaluates a condition).


## Method-backed because class references are not constant expressions.
func _base_type_cases() -> Array[Array]:
	var cases: Array[Array] = [
		[BT_LeafTask],
		[BehaviorTask],
	]
	for case in cases:
		assert_array(case).is_not_empty()
	return cases


func test_condition_leaf_is_a_task_type(
	base_type: GDScript, _test_parameters := _base_type_cases()
) -> void:
	var leaf: Node = auto_free(ConcreteConditionLeaf.new())

	assert_object(leaf).is_instanceof(base_type)


class ConcreteConditionLeaf:
	extends BT_ConditionLeaf

	func _tick(_delta: float) -> Status:
		return SUCCESS
