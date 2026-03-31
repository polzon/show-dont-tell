class_name TestSelectorComposite
extends GdUnitTestSuite
## Test the BT_SelectorComposite (executes children until success).


func test_selector_composite_created() -> void:
	var composite := ConcreteSelectorComposite.new()

	assert_that(composite).is_not_null()

	composite.free()


func test_selector_composite_is_composite_task() -> void:
	var composite := ConcreteSelectorComposite.new()

	assert_object(composite).is_instanceof(BT_CompositeTask)
	assert_object(composite).is_instanceof(BehaviorTask)

	composite.free()


# Concrete implementation for testing
class ConcreteSelectorComposite:
	extends BT_SelectorComposite

	func _tick(_delta: float) -> Status:
		return SUCCESS
