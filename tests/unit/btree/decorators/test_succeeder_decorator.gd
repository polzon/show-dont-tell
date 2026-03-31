class_name TestSucceederDecorator
extends GdUnitTestSuite
## Test the BT_SucceederDecorator (returns SUCCESS regardless).


func test_succeeder_decorator_created() -> void:
	var decorator := ConcreteSucceederDecorator.new()

	assert_that(decorator).is_not_null()

	decorator.free()


func test_succeeder_decorator_is_decorator_task() -> void:
	var decorator := ConcreteSucceederDecorator.new()

	assert_object(decorator).is_instanceof(BT_DecoratorTask)
	assert_object(decorator).is_instanceof(BehaviorTask)

	decorator.free()


# Concrete implementation for testing
class ConcreteSucceederDecorator:
	extends BT_SucceederDecorator

	func _tick(_delta: float) -> Status:
		return SUCCESS
