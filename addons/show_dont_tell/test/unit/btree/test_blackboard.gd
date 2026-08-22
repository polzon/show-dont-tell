class_name TestBlackboard
extends GdUnitTestSuite
## Test the BT_Blackboard class.

var _blackboard: BT_Blackboard


func before_test() -> void:
	_blackboard = auto_free(BT_Blackboard.new())


func test_blackboard_is_node() -> void:
	assert_that(_blackboard is Node).is_true()


func test_blackboard_finds_behavior_tree_parent() -> void:
	var bt: TestBehaviorTree = auto_free(TestBehaviorTree.new())
	bt.enabled = false
	add_child(bt)

	var blackboard: BT_Blackboard = auto_free(BT_Blackboard.new())
	bt.add_child(blackboard)

	assert_that(blackboard.behavior_tree).is_equal(bt)


func test_set_and_get_data_roundtrip() -> void:
	var key := &"health"
	var value := 42

	_blackboard.set_data(key, value)

	assert_that(_blackboard.get_data(key)).is_equal(value)


func test_get_missing_data_returns_null() -> void:
	assert_that(_blackboard.get_data(&"missing")).is_null()


class TestBehaviorTree:
	extends BehaviorTree

	func _tick(_delta: float) -> Status:
		return SUCCESS
