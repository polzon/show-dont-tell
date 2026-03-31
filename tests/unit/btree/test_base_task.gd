class_name TestBaseTask
extends GdUnitTestSuite
## Test the BaseTask (BehaviorTask) class.


func test_status_enum_values() -> void:
	assert_that(BehaviorTask.Status.SUCCESS).is_equal(0)
	assert_that(BehaviorTask.Status.FAILED).is_equal(1)
	assert_that(BehaviorTask.Status.RUNNING).is_equal(2)
	assert_that(BehaviorTask.Status.NULL).is_equal(-1)


func test_initial_status_is_success() -> void:
	var task := _create_test_task()

	assert_that(task.status).is_equal(BehaviorTask.SUCCESS)


func test_execute_returns_status() -> void:
	var bt := _create_behavior_tree()
	var task: TestTask = bt.get_child(0)

	var status := task.execute(0.016)

	assert_that(status).is_equal(BehaviorTask.SUCCESS)


func test_execute_emits_task_started() -> void:
	var bt := _create_behavior_tree()
	var task: TestTask = bt.get_child(0)

	assert_signal(task).is_emitted("task_started")
	task.execute(0.016)


func test_execute_emits_task_ended() -> void:
	var bt := _create_behavior_tree()
	var task: TestTask = bt.get_child(0)

	assert_signal(task).is_emitted("task_ended")
	task.execute(0.016)


func test_child_task_discovery() -> void:
	var parent := TestTask.new()
	add_child(parent)

	var child1 := TestTask.new()
	child1.name = "Child1"
	parent.add_child(child1)

	var child2 := TestTask.new()
	child2.name = "Child2"
	parent.add_child(child2)

	var found_tasks := parent._find_child_tasks()

	assert_that(found_tasks.size()).is_equal(2)
	assert_that(found_tasks[0]).is_equal(child1)
	assert_that(found_tasks[1]).is_equal(child2)


func test_parent_task_reference() -> void:
	var parent := TestTask.new()
	add_child(parent)

	var child := TestTask.new()
	parent.add_child(child)

	assert_that(child.parent_task).is_equal(parent)


func test_behavior_tree_assignment() -> void:
	var bt := _create_behavior_tree()
	var task: TestTask = bt.get_child(0)

	assert_that(task.behavior_tree).is_equal(bt)


func test_behavior_tree_propagates_to_children() -> void:
	var bt := _create_behavior_tree()
	var task: TestTask = bt.get_child(0)

	var child := TestTask.new()
	child.name = "Child"
	task.add_child(child)

	assert_that(child.behavior_tree).is_equal(bt)


func test_get_child_task_returns_first_child() -> void:
	var task := TestTask.new()
	add_child(task)

	var child := TestTask.new()
	task.add_child(child)

	var result := task._get_child_task()

	assert_that(result).is_equal(child)


func test_get_child_task_returns_null_if_no_children() -> void:
	var task := TestTask.new()
	add_child(task)

	var result := task._get_child_task()

	assert_that(result).is_null()


func test_execute_child() -> void:
	var bt := _create_behavior_tree()
	var parent: TestTask = bt.get_child(0)

	var child := TestTask.new()
	child.name = "Child"
	child.behavior_tree = bt
	parent.add_child(child)

	var status := parent._execute_child(0.016)

	assert_that(status).is_equal(BehaviorTask.SUCCESS)


func test_task_index_setter_clamps_value() -> void:
	var task := TestTask.new()
	add_child(task)

	var child1 := TestTask.new()
	task.add_child(child1)
	var child2 := TestTask.new()
	task.add_child(child2)

	task.task_index = 10  # Beyond range

	assert_that(task.task_index).is_equal(1)  # Clamped to max (size - 1)


func test_next_task_increments_index() -> void:
	var task := TestTask.new()
	add_child(task)

	var child1 := TestTask.new()
	child1.name = "Child1"
	task.add_child(child1)

	var child2 := TestTask.new()
	child2.name = "Child2"
	task.add_child(child2)

	task.task_index = 0
	var next := task.next_task()

	assert_that(next).is_equal(child2)
	assert_that(task.task_index).is_equal(1)


func test_next_task_wraps_around() -> void:
	var task := TestTask.new()
	add_child(task)

	var child1 := TestTask.new()
	task.add_child(child1)

	var child2 := TestTask.new()
	task.add_child(child2)

	task.task_index = 1
	var next := task.next_task()

	assert_that(next).is_equal(child1)
	assert_that(task.task_index).is_equal(0)


func test_first_task_resets_index() -> void:
	var task := TestTask.new()
	add_child(task)

	var child1 := TestTask.new()
	task.add_child(child1)

	var child2 := TestTask.new()
	task.add_child(child2)

	task.task_index = 1
	var first := task.first_task()

	assert_that(first).is_equal(child1)
	assert_that(task.task_index).is_equal(0)


# Helper functions
func _create_test_task() -> BehaviorTask:
	var task := TestTask.new()
	add_child(task)
	return task


func _create_behavior_tree() -> BehaviorTree:
	var bt := TestBehaviorTree.new()
	bt.name = "TestBehaviorTree"
	add_child(bt)

	var root_task := TestTask.new()
	root_task.name = "RootTask"
	bt.add_child(root_task)
	bt._find_child_tasks()

	return bt


# Test classes
class TestBehaviorTree:
	extends BehaviorTree

	func _tick(_delta: float) -> Status:
		return SUCCESS


class TestTask:
	extends BehaviorTask

	func _tick(_delta: float) -> Status:
		return SUCCESS
