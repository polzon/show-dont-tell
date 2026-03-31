class_name TestLimiterDecorator
extends GdUnitTestSuite
## Test the BT_LimiterDecorator (limits execution count).


func test_limiter_decorator_created() -> void:
	var decorator := ConcreteLimiterDecorator.new()

	assert_that(decorator).is_not_null()

	decorator.free()


func test_limiter_decorator_is_decorator_task() -> void:
	var decorator := ConcreteLimiterDecorator.new()

	assert_object(decorator).is_instanceof(BT_DecoratorTask)
	assert_object(decorator).is_instanceof(BehaviorTask)

	decorator.free()


# Concrete implementation for testing
class ConcreteLimiterDecorator:
	extends BT_LimiterDecorator

	func _tick(_delta: float) -> Status:
		return SUCCESS
