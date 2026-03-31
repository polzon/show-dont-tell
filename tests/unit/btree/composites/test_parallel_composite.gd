class_name TestParallelComposite
extends GdUnitTestSuite
## Test the BT_ParallelComposite (executes all children simultaneously).


func test_parallel_composite_created() -> void:
	var composite := ConcreteParallelComposite.new()

	assert_that(composite).is_not_null()

	composite.free()


func test_parallel_composite_is_composite_task() -> void:
	var composite := ConcreteParallelComposite.new()

	assert_object(composite).is_instanceof(BT_CompositeTask)
	assert_object(composite).is_instanceof(BehaviorTask)

	composite.free()


# Concrete implementation for testing
class ConcreteParallelComposite:
	extends BT_ParallelComposite

	func _tick(_delta: float) -> Status:
		return SUCCESS
