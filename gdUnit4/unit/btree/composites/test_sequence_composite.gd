class_name TestSequenceComposite
extends GdUnitTestSuite
## Test the BT_SequenceComposite (executes children in order).


func test_sequence_composite_created() -> void:
	var composite := ConcreteSequenceComposite.new()

	assert_that(composite).is_not_null()

	composite.free()


func test_sequence_composite_is_composite_task() -> void:
	var composite := ConcreteSequenceComposite.new()

	assert_object(composite).is_instanceof(BT_CompositeTask)
	assert_object(composite).is_instanceof(BehaviorTask)

	composite.free()


# Concrete implementation for testing
class ConcreteSequenceComposite:
	extends BT_SequenceComposite

	func _tick(_delta: float) -> Status:
		return SUCCESS
