class_name TestActionLeaf
extends GdUnitTestSuite
## Test the BT_ActionLeaf (executes an command).


func test_action_leaf_created() -> void:
	var leaf := ConcreteActionLeaf.new()

	assert_that(leaf).is_not_null()

	leaf.free()


func test_action_leaf_is_leaf_task() -> void:
	var leaf := ConcreteActionLeaf.new()

	assert_that(leaf is BT_LeafTask).is_equal(true)
	assert_that(leaf is BehaviorTask).is_equal(true)

	leaf.free()


# Concrete implementation for testing
class ConcreteActionLeaf:
	extends BT_ActionLeaf

	func _tick(_delta: float) -> Status:
		return SUCCESS
