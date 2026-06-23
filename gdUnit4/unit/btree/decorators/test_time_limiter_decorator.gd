class_name TestTimeLimiterDecorator
extends GdUnitTestSuite
## Test the BT_TimeLimiterDecorator (limits execution duration).


func test_time_limiter_decorator_created() -> void:
	var decorator := ConcreteTimeLimiterDecorator.new()

	assert_that(decorator).is_not_null()

	decorator.free()


func test_time_limiter_decorator_is_decorator_task() -> void:
	var decorator := ConcreteTimeLimiterDecorator.new()

	assert_object(decorator).is_instanceof(BT_DecoratorTask)
	assert_object(decorator).is_instanceof(BehaviorTask)

	decorator.free()


# Concrete implementation for testing
class ConcreteTimeLimiterDecorator:
	extends BT_TimeLimiterDecorator

	func _tick(_delta: float) -> Status:
		return SUCCESS
