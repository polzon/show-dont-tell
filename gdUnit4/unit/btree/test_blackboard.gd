class_name TestBlackboard
extends GdUnitTestSuite
## Test the Blackboard (BT_Blackboard) class.


func test_blackboard_creation() -> void:
	var blackboard := BT_Blackboard.new()
	add_child(blackboard)

	assert_that(blackboard).is_not_null()
	blackboard.queue_free()
	await get_tree().process_frame


func test_blackboard_is_node() -> void:
	var blackboard := BT_Blackboard.new()
	add_child(blackboard)

	assert_that(blackboard is Node).is_equal(true)
	blackboard.queue_free()
	await get_tree().process_frame


func test_blackboard_parent_assignment() -> void:
	var parent := Node.new()
	parent.name = "Parent"
	add_child(parent)

	var blackboard := BT_Blackboard.new()
	blackboard.name = "Blackboard"
	parent.add_child(blackboard)

	assert_that(blackboard.get_parent()).is_equal(parent)

	# Cleanup
	parent.queue_free()
	await get_tree().process_frame


# Helper functions
func _create_behavior_tree() -> BehaviorTree:
	var bt := TestBehaviorTree.new()
	bt.name = "TestBehaviorTree"
	add_child(bt)

	var root_task := TestTask.new()
	root_task.name = "RootTask"
	bt.add_child(root_task)

	return bt


func _cleanup_behavior_tree(bt: BehaviorTree) -> void:
	for child in bt.get_children():
		if is_instance_valid(child):
			child.queue_free()
	bt.queue_free()
	await get_tree().process_frame


# Test classes
class TestBehaviorTree:
	extends BehaviorTree

	func _tick(_delta: float) -> Status:
		return SUCCESS


class TestTask:
	extends BehaviorTask

	func _tick(_delta: float) -> Status:
		return SUCCESS
