class_name TestSucceederDecorator
extends GdUnitTestSuite
## Test the BT_SucceederDecorator (returns SUCCESS regardless).


## Method-backed because class references are not constant expressions.
func _base_type_cases() -> Array[Array]:
	var cases: Array[Array] = [
		[BT_DecoratorTask],
		[BehaviorTask],
	]
	for case in cases:
		assert_array(case).is_not_empty()
	return cases


func test_succeeder_decorator_is_a_task_type(
	base_type: GDScript, _test_parameters := _base_type_cases()
) -> void:
	var decorator: Node = auto_free(ConcreteSucceederDecorator.new())

	assert_object(decorator).is_instanceof(base_type)


class ConcreteSucceederDecorator:
	extends BT_SucceederDecorator

	func _tick(_delta: float) -> Status:
		return SUCCESS
