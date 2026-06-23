class_name TestInverterDecorator
extends GdUnitTestSuite
## Test the BT_InverterDecorator (inverts SUCCESS/FAILED).


func test_inverter_decorator_created() -> void:
	var decorator := ConcreteInverterDecorator.new()

	assert_that(decorator).is_not_null()

	decorator.free()


func test_inverter_decorator_is_decorator_task() -> void:
	var decorator := ConcreteInverterDecorator.new()

	assert_object(decorator).is_instanceof(BT_DecoratorTask)
	assert_object(decorator).is_instanceof(BehaviorTask)

	decorator.free()


# Concrete implementation for testing
class ConcreteInverterDecorator:
	extends BT_InverterDecorator

	func _tick(_delta: float) -> Status:
		return SUCCESS
