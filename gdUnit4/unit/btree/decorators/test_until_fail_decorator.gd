class_name TestUntilFailDecorator
extends GdUnitTestSuite
## Test the BT_UntilFailDecorator (repeats until child fails).


func test_until_fail_decorator_created() -> void:
	var decorator := ConcreteUntilFailDecorator.new()

	assert_that(decorator).is_not_null()

	decorator.free()


func test_until_fail_decorator_is_decorator_task() -> void:
	var decorator := ConcreteUntilFailDecorator.new()

	assert_object(decorator).is_instanceof(BT_DecoratorTask)
	assert_object(decorator).is_instanceof(BehaviorTask)

	decorator.free()


# Concrete implementation for testing
class ConcreteUntilFailDecorator:
	extends BT_UntilFailDecorator

	func _tick(_delta: float) -> Status:
		return SUCCESS
