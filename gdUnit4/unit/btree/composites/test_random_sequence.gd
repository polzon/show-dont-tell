class_name TestRandomSequence
extends GdUnitTestSuite
## Test the BT_RandomSequence (shuffles child order).


func test_random_sequence_created() -> void:
	var composite := ConcreteRandomSequence.new()

	assert_that(composite).is_not_null()

	composite.free()


func test_random_sequence_is_composite_task() -> void:
	var composite := ConcreteRandomSequence.new()

	assert_object(composite).is_instanceof(BT_CompositeTask)
	assert_object(composite).is_instanceof(BehaviorTask)

	composite.free()


# Concrete implementation for testing
class ConcreteRandomSequence:
	extends BT_RandomSequence

	func _tick(_delta: float) -> Status:
		return SUCCESS
