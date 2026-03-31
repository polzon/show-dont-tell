class_name TestConditionLeaf
extends GdUnitTestSuite
## Test the BT_ConditionLeaf (evaluates a condition).


func test_condition_leaf_created() -> void:
	var leaf := ConcreteConditionLeaf.new()

	assert_that(leaf).is_not_null()

	leaf.free()


func test_condition_leaf_is_leaf_task() -> void:
	var leaf := ConcreteConditionLeaf.new()

	assert_that(leaf is BT_LeafTask).is_equal(true)
	assert_that(leaf is BehaviorTask).is_equal(true)

	leaf.free()


# Concrete implementation for testing
class ConcreteConditionLeaf:
	extends BT_ConditionLeaf

	func _tick(_delta: float) -> Status:
		return SUCCESS
