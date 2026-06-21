class_name TestDelayerDecorator
extends GdUnitTestSuite
## Test the BT_DelayerDecorator (delays before executing child).


func test_delayer_decorator_created() -> void:
	var decorator := ConcreteDelayerDecorator.new()

	assert_that(decorator).is_not_null()

	decorator.free()


func test_delayer_decorator_is_decorator_task() -> void:
	var decorator := ConcreteDelayerDecorator.new()

	assert_object(decorator).is_instanceof(BT_DecoratorTask)
	assert_object(decorator).is_instanceof(BehaviorTask)

	decorator.free()


# Concrete implementation for testing
class ConcreteDelayerDecorator:
	extends BT_DelayerDecorator

	func _tick(_delta: float) -> Status:
		return SUCCESS
