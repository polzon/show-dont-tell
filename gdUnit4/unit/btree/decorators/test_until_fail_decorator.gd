class_name TestUntilFailDecorator
extends GdUnitTestSuite
## Test the BT_UntilFailDecorator (repeats until child fails).


## Method-backed because class references are not constant expressions.
func _base_type_cases() -> Array[Array]:
	var cases: Array[Array] = [
		[BT_DecoratorTask],
		[BehaviorTask],
	]
	for case in cases:
		assert_array(case).is_not_empty()
	return cases


func test_until_fail_decorator_is_a_task_type(
	base_type: GDScript, _test_parameters := _base_type_cases()
) -> void:
	var decorator: Node = auto_free(ConcreteUntilFailDecorator.new())

	assert_object(decorator).is_instanceof(base_type)


class ConcreteUntilFailDecorator:
	extends BT_UntilFailDecorator

	func _tick(_delta: float) -> Status:
		return SUCCESS
