class_name TestSelectorComposite
extends GdUnitTestSuite
## Test the BT_SelectorComposite (executes children until success).


## Method-backed because class references are not constant expressions.
func _base_type_cases() -> Array[Array]:
	var cases: Array[Array] = [
		[BT_CompositeTask],
		[BehaviorTask],
	]
	for case in cases:
		assert_array(case).is_not_empty()
	return cases


func test_selector_composite_is_a_task_type(
	base_type: GDScript, _test_parameters := _base_type_cases()
) -> void:
	var composite: Node = auto_free(ConcreteSelectorComposite.new())

	assert_object(composite).is_instanceof(base_type)


class ConcreteSelectorComposite:
	extends BT_SelectorComposite

	func _tick(_delta: float) -> Status:
		return SUCCESS
