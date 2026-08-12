class_name TestSequenceComposite
extends GdUnitTestSuite
## Test the BT_SequenceComposite (executes children in order).


## Method-backed because class references are not constant expressions.
func _base_type_cases() -> Array[Array]:
	var cases: Array[Array] = [
		[BT_CompositeTask],
		[BehaviorTask],
	]
	for case in cases:
		assert_array(case).is_not_empty()
	return cases


func test_sequence_composite_is_a_task_type(
	base_type: GDScript, _test_parameters := _base_type_cases()
) -> void:
	var composite: Node = auto_free(ConcreteSequenceComposite.new())

	assert_object(composite).is_instanceof(base_type)


class ConcreteSequenceComposite:
	extends BT_SequenceComposite

	func _tick(_delta: float) -> Status:
		return SUCCESS
