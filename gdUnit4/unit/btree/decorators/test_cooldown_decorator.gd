class_name TestCooldownDecorator
extends GdUnitTestSuite
## Test the BT_CooldownDecorator (blocks execution during cooldown).


func test_cooldown_decorator_created() -> void:
	var decorator := ConcreteCooldownDecorator.new()

	assert_that(decorator).is_not_null()

	decorator.free()


func test_cooldown_decorator_is_decorator_task() -> void:
	var decorator := ConcreteCooldownDecorator.new()

	assert_object(decorator).is_instanceof(BT_DecoratorTask)
	assert_object(decorator).is_instanceof(BehaviorTask)

	decorator.free()


# Concrete implementation for testing
class ConcreteCooldownDecorator:
	extends BT_CooldownDecorator

	func _tick(_delta: float) -> Status:
		return SUCCESS
