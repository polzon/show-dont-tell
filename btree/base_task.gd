@abstract
@icon("res://addons/show_not_tell/icons/category_bt.svg")
class_name BT_BaseTask
extends BaseState
## The core of a [BehaviorTree] task that everything is extended from.

# TODO:
# - I keep swapping the usage of State and Task interchangably. Maybe I should
#   settles on renaming them all one or the other? (Probably would
#   go with State.)

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

@onready var parent_task := get_parent() as BT_BaseTask
@onready var child_tasks: Array[BT_BaseTask] = _find_child_tasks()
var task_index: int = 0:
	set = set_task_index


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
	status = _process_tick(delta)
	if status != RUNNING:
		_exited_state()

	assert(status != Status.NULL,
			"Error status: %s" % Status.find_key(status))
	return status


func prev_task() -> BT_BaseTask:
	task_index -= 1
	return child_tasks[task_index]


func next_task() -> BT_BaseTask:
	if task_index >= child_tasks.size() - 1:
		task_index = 0
	else:
		task_index += 1
	return child_tasks[task_index]


func first_task() -> BT_BaseTask:
	task_index = 0
	return child_tasks[task_index]


func set_task_index(index: int) -> void:
	task_index = clampi(index, 0, child_tasks.size() - 1)


func set_behavior_tree(tree: BehaviorTree) -> void:
	behavior_tree = tree
	if is_instance_valid(behavior_tree):
		_assign_behavior_tree()


## Base process tick function that is triggered every [BehaviorTree]
## process updates. This function updates every possible frame.
func _process_tick(_delta: float) -> Status:
	return FAILED


func _find_child_tasks() -> Array[BT_BaseTask]:
	var tasks: Array[BT_BaseTask] = []
	for node in get_children(false):
		if is_instance_valid(node) and node is BT_BaseTask:
			tasks.push_back(node)
	return tasks


func _assign_behavior_tree() -> void:
	for task in child_tasks:
		task.behavior_tree = behavior_tree


func _update_child_tasks() -> void:
	child_tasks = _find_child_tasks()
