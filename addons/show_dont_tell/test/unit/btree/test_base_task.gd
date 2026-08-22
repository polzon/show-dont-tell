class_name TestBaseTask
extends GdUnitTestSuite
## Test the BehaviorTask base class.

const FUZZER_ITERATIONS: int = 20
const DELTA := 0.016
const CHILD_COUNT: int = 3

const STATUS_CASES: Array[Array] = [
	[BehaviorTask.Status.SUCCESS, 0],
	[BehaviorTask.Status.FAILED, 1],
	[BehaviorTask.Status.RUNNING, 2],
	[BehaviorTask.Status.NULL, -1],
]


func test_status_enum_values() -> void:
	for case: Array in STATUS_CASES:
		assert_int(case[0]).is_equal(case[1])


func test_initial_status_is_success() -> void:
	var task := _create_test_task()

	assert_that(task.status).is_equal(BehaviorTask.SUCCESS)


func test_execute_returns_status() -> void:
	var bt := _create_behavior_tree()
	var task: TestTask = bt.get_child(0)

	var status := task.execute(DELTA)

	assert_that(status).is_equal(BehaviorTask.SUCCESS)


func test_execute_emits_task_started() -> void:
	var bt := _create_behavior_tree()
	var task: TestTask = bt.get_child(0)

	assert_signal(task).is_emitted("task_started")
	task.execute(DELTA)


func test_execute_emits_task_ended() -> void:
	var bt := _create_behavior_tree()
	var task: TestTask = bt.get_child(0)

	assert_signal(task).is_emitted("task_ended")
	task.execute(DELTA)


func test_child_task_discovery() -> void:
	var parent := _create_task_with_children(2)

	var found := parent._find_child_tasks()

	assert_int(found.size()).is_equal(2)
	assert_that(found[0]).is_same(parent.child_tasks[0])
	assert_that(found[1]).is_same(parent.child_tasks[1])


func test_parent_task_reference() -> void:
	var parent := _create_task_with_children(1)
	var child := parent.child_tasks[0]

	assert_that(child.parent_task).is_equal(parent)


func test_behavior_tree_assignment() -> void:
	var bt := _create_behavior_tree()
	var task := bt.get_child(0) as BehaviorTask

	assert_that(task.behavior_tree).is_equal(bt)


func test_behavior_tree_propagates_to_children() -> void:
	var bt := _create_behavior_tree()
	var task := bt.get_child(0) as BehaviorTask
	var child := TestTask.new()
	task.add_child(child)

	assert_that(child.behavior_tree).is_equal(bt)


func test_get_child_task_returns_first() -> void:
	var task := _create_task_with_children(1)

	assert_that(task._get_child_task()).is_same(task.child_tasks[0])


func test_get_child_task_returns_null() -> void:
	var task := _create_test_task()

	assert_that(task._get_child_task()).is_null()


func test_execute_child() -> void:
	var bt := _create_behavior_tree()
	var parent := bt.get_child(0) as BehaviorTask
	parent.add_child(TestTask.new())

	var status := parent._execute_child(DELTA)

	assert_that(status).is_equal(BehaviorTask.SUCCESS)


## task_index clamps to the child range; negatives and over-range indices
## must not reach invalid child_tasks positions.
func test_index_setter_clamps(
	fuzzer_index := Fuzzers.rangei(-10, 10),
	_fuzzer_iterations := FUZZER_ITERATIONS,
) -> void:
	var task := _create_task_with_children(CHILD_COUNT)
	var raw_index := fuzzer_index.next_value()

	task.task_index = raw_index

	assert_int(task.task_index).is_equal(clampi(raw_index, 0, CHILD_COUNT - 1))


## next_task advances one child and wraps from the last child back to the
## first; the child returned must be the one at the wrapped index.
func test_next_task_advances_or_wraps(
	fuzzer_index := Fuzzers.rangei(0, CHILD_COUNT - 1),
	_fuzzer_iterations := FUZZER_ITERATIONS,
) -> void:
	var task := _create_task_with_children(CHILD_COUNT)
	var start_index := fuzzer_index.next_value()
	task.task_index = start_index
	var expected_index := (start_index + 1) % CHILD_COUNT

	var next := task.next_task()

	assert_int(task.task_index).is_equal(expected_index)
	assert_that(next).is_same(task.child_tasks[expected_index])


## first_task always returns the leading child and resets the index to zero,
## regardless of where the index currently sits.
func test_first_task_resets_index(
	fuzzer_index := Fuzzers.rangei(0, CHILD_COUNT - 1),
	_fuzzer_iterations := FUZZER_ITERATIONS,
) -> void:
	var task := _create_task_with_children(CHILD_COUNT)
	task.task_index = fuzzer_index.next_value()

	var first := task.first_task()

	assert_int(task.task_index).is_zero()
	assert_that(first).is_same(task.child_tasks[0])


func _create_test_task() -> BehaviorTask:
	var task: TestTask = auto_free(TestTask.new())
	add_child(task)
	return task


func _create_task_with_children(count: int) -> BehaviorTask:
	var task := _create_test_task()
	for i in count:
		var child: TestTask = auto_free(TestTask.new())
		task.add_child(child)
	return task


func _create_behavior_tree() -> BehaviorTree:
	var bt: TestBehaviorTree = auto_free(TestBehaviorTree.new())
	bt.name = "TestBehaviorTree"
	add_child(bt)

	var root_task := TestTask.new()
	root_task.name = "RootTask"
	bt.add_child(root_task)
	bt._find_child_tasks()

	return bt


class TestBehaviorTree:
	extends BehaviorTree

	func _tick(_delta: float) -> Status:
		return SUCCESS


class TestTask:
	extends BehaviorTask

	func _tick(_delta: float) -> Status:
		return SUCCESS
