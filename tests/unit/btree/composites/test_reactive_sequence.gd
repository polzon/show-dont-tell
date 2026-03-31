class_name TestReactiveSequence
extends GdUnitTestSuite
## Test the BT_ReactiveSequence (restarts children each tick).


func test_reactive_sequence_created() -> void:
	var composite := ConcreteReactiveSequence.new()

	assert_that(composite).is_not_null()

	composite.free()


func test_reactive_sequence_is_composite_task() -> void:
	var composite := ConcreteReactiveSequence.new()

	assert_object(composite).is_instanceof(BT_CompositeTask)
	assert_object(composite).is_instanceof(BehaviorTask)

	composite.free()


# Concrete implementation for testing
class ConcreteReactiveSequence:
	extends BT_ReactiveSequence

	func _tick(_delta: float) -> Status:
		return SUCCESS
