class_name TestFailerDecorator
extends GdUnitTestSuite
## Test the BT_FailerDecorator (returns FAILED regardless).


func test_failer_decorator_created() -> void:
	var decorator := ConcreteFailerDecorator.new()

	assert_that(decorator).is_not_null()

	decorator.free()


func test_failer_decorator_is_decorator_task() -> void:
	var decorator := ConcreteFailerDecorator.new()

	assert_object(decorator).is_instanceof(BT_DecoratorTask)
	assert_object(decorator).is_instanceof(BehaviorTask)

	decorator.free()


# Concrete implementation for testing
class ConcreteFailerDecorator:
	extends BT_FailerDecorator

	func _tick(_delta: float) -> Status:
		return SUCCESS
