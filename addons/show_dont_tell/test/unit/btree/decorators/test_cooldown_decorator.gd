class_name TestCooldownDecorator
extends GdUnitTestSuite
## Test the BT_CooldownDecorator (blocks execution during cooldown).


## Method-backed because class references are not constant expressions.
func _base_type_cases() -> Array[Array]:
	var cases: Array[Array] = [
		[BT_DecoratorTask],
		[BehaviorTask],
	]
	for case in cases:
		assert_array(case).is_not_empty()
	return cases


func test_cooldown_decorator_is_a_task_type(
	base_type: GDScript, _test_parameters := _base_type_cases()
) -> void:
	var decorator: Node = auto_free(ConcreteCooldownDecorator.new())

	assert_object(decorator).is_instanceof(base_type)


class ConcreteCooldownDecorator:
	extends BT_CooldownDecorator

	func _tick(_delta: float) -> Status:
		return SUCCESS
