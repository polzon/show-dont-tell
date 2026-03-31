class_name TestReactiveSelector
extends GdUnitTestSuite
## Test the BT_ReactiveSelector (re-evaluates children each tick).


func test_reactive_selector_created() -> void:
	var composite := ConcreteReactiveSelector.new()

	assert_that(composite).is_not_null()

	composite.free()


func test_reactive_selector_is_composite_task() -> void:
	var composite := ConcreteReactiveSelector.new()

	assert_object(composite).is_instanceof(BT_CompositeTask)
	assert_object(composite).is_instanceof(BehaviorTask)

	composite.free()


# Concrete implementation for testing
class ConcreteReactiveSelector:
	extends BT_ReactiveSelector

	func _tick(_delta: float) -> Status:
		return SUCCESS
