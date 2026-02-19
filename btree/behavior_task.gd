@abstract
@icon("res://addons/show_not_tell/icons/category_bt.svg")
class_name BehaviorTask
extends BaseState
## The core of a [BehaviorTree] task that everything is extended from.

# TODO:
# - I keep swapping the usage of State and Task interchangably. Maybe I should
#   settles on renaming them all one or the other? (Probably would
#   go with State.)

signal task_started
signal task_ended

enum Status {
	## The task has succeeded in its goal.
	SUCCESS = 0,
	## The task has failed its goal.
	FAILED = 1,
	## The task needs more time to run.
	RUNNING = 2,
	## For error handling.
	NULL = -1,
}
const SUCCESS = Status.SUCCESS
const FAILED = Status.FAILED
const RUNNING = Status.RUNNING

var status := SUCCESS
var behavior_tree: BehaviorTree:
	set = set_behavior_tree
var blackboard: BT_Blackboard:
	get():
		if not blackboard:
			blackboard = (
				_get_child_state_custom(BT_Blackboard, false) as BT_Blackboard
			)
		return blackboard
var task_index: int = 0:
	set = set_task_index

@onready var parent_task := get_parent() as BehaviorTask
@onready var child_tasks: Array[BehaviorTask] = _find_child_tasks()


func _enter_tree() -> void:
	child_order_changed.connect(_update_child_tasks)
	child_order_changed.connect(_assign_behavior_tree)


func _exit_tree() -> void:
	child_order_changed.disconnect(_update_child_tasks)
	child_order_changed.disconnect(_assign_behavior_tree)


func execute(delta: float) -> Status:
	assert(behavior_tree, "Missing behavior tree!")
	behavior_tree.process_chain.push_back(self)

	if status != RUNNING:
		_entered_state()
		task_started.emit()

	status = _tick(delta)

	if status != RUNNING:
		_exited_state()
		task_ended.emit()
	elif (
		status == RUNNING
		and self is BT_LeafTask
		and behavior_tree.running_task != self
	):
		behavior_tree.running_task = self

	assert(status != Status.NULL, "Error status: %s" % Status.find_key(status))
	return status


func interrupt() -> void:
	if status == RUNNING:
		_exited_state()
		task_ended.emit()
	status = FAILED


func prev_task() -> BehaviorTask:
	task_index -= 1
	return child_tasks[task_index]


func next_task() -> BehaviorTask:
	if task_index >= child_tasks.size() - 1:
		task_index = 0
	else:
		task_index += 1
	return child_tasks[task_index]


func first_task() -> BehaviorTask:
	task_index = 0
	return child_tasks[task_index]


func get_child_task(type: GDScript) -> BehaviorTask:
	var task := get_child_state(type) as BehaviorTask
	assert(
		is_instance_valid(task),
		"Failed to get task: %s" % type.get_global_name()
	)
	return task


func set_task_index(index: int) -> void:
	task_index = clampi(index, 0, child_tasks.size() - 1)


func set_behavior_tree(tree: BehaviorTree) -> void:
	behavior_tree = tree
	if is_instance_valid(behavior_tree):
		_assign_behavior_tree()


func get_current_task() -> BehaviorTask:
	assert(
		behavior_tree and behavior_tree.current_task,
		"Failed to find current task."
	)
	return behavior_tree.current_task if behavior_tree else null


func get_running_task() -> BehaviorTask:
	assert(
		behavior_tree and behavior_tree.running_task,
		"Failed to find running task."
	)
	return behavior_tree.running_task if behavior_tree else null


func is_current_task() -> bool:
	return get_current_task() == self


func is_running_task() -> bool:
	return get_running_task() == self


## Base process tick function that is triggered every [BehaviorTree]
## process updates. This function updates every possible frame.
func _tick(_delta: float) -> Status:
	return SUCCESS


func _process_tick(_delta: float) -> void:
	return


func _physics_tick(_delta: float) -> void:
	pass


func _handle_action(_action: Action) -> void:
	pass


func _get_child_task() -> BehaviorTask:
	return null if child_tasks.is_empty() else child_tasks[0]


func _execute_child(delta: float) -> Status:
	var child := _get_child_task()
	if not child:
		return FAILED
	return child.execute(delta)


func _find_child_tasks() -> Array[BehaviorTask]:
	var tasks: Array[BehaviorTask] = []
	for node in get_children(false):
		if is_instance_valid(node) and node is BehaviorTask:
			tasks.push_back(node)
	return tasks


func _assign_behavior_tree() -> void:
	for task in child_tasks:
		task.behavior_tree = behavior_tree


func _update_child_tasks() -> void:
	child_tasks = _find_child_tasks()


func _assert_current_task() -> void:
	assert(
		is_current_task(),
		(
			"Asserting task %s does not match current task: %s"
			% [
				self.name,
				get_current_task().name if get_current_task() else &""
			]
		)
	)


func _assert_running_task() -> void:
	assert(
		is_running_task(),
		(
			"Asserting task %s does not match running task: %s"
			% [
				self.name,
				get_running_task().name if get_running_task() else &""
			]
		)
	)
