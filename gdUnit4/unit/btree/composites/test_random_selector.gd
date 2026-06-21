class_name TestRandomSelector
extends GdUnitTestSuite
## Test the BT_RandomSelector (randomizes child order).


func test_random_selector_created() -> void:
	var composite := ConcreteRandomSelector.new()

	assert_that(composite).is_not_null()

	composite.free()


func test_random_selector_is_composite_task() -> void:
	var composite := ConcreteRandomSelector.new()

	assert_object(composite).is_instanceof(BT_CompositeTask)
	assert_object(composite).is_instanceof(BehaviorTask)

	composite.free()


# Concrete implementation for testing
class ConcreteRandomSelector:
	extends BT_RandomSelector

	func _tick(_delta: float) -> Status:
		return SUCCESS
