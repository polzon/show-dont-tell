@abstract
@icon("res://addons/show_not_tell/icons/category_bt.svg")
class_name BT_BaseTask
extends Node
## The core of a [BehaviorTree] task that everything is extended from.

enum Status {
	SUCCESS,
	FAILED,
	RUNNING
}
const SUCCESS = Status.SUCCESS
const FAILED = Status.FAILED
const RUNNING = Status.RUNNING

var behavior_tree: BehaviorTree:
	set = set_behavior_tree

@onready var parent_task: BT_BaseTask = _find_parent_task()
@onready var child_tasks: Array[BT_BaseTask] = _find_child_tasks()


func _enter_tree() -> void:
	child_order_changed.connect(_update_child_tasks)
	child_order_changed.connect(_assign_behavior_tree)
	parent_task = _find_parent_task()


func _exit_tree() -> void:
	child_order_changed.disconnect(_update_child_tasks)
	child_order_changed.disconnect(_assign_behavior_tree)
	parent_task = null


## Base process tick function that is triggered every [BehaviorTree]
## process updates. This function updates every possible frame.
@abstract
func _process_tick(delta: float) -> Status


## Base physics tick function that is triggered every [BehaviorTree]
## physics update. This function updates every physics update.
func _physics_tick(_delta: float) -> Status:
	return FAILED


func _on_task_start() -> void:
	pass


func _on_task_end() -> void:
	pass


func set_behavior_tree(tree: BehaviorTree) -> void:
	behavior_tree = tree
	if is_instance_valid(behavior_tree):
		_assign_behavior_tree()


## Default task behavior. Processes the children and returning if a
## child returns true.
func _process_sequentual(delta: float) -> Status:
	for task: BT_BaseTask in child_tasks:
		var result := task._process_tick(delta)
		if result != FAILED:
			return result
	return FAILED


func _find_parent_task() -> BT_BaseTask:
	var base_task := get_parent() as BT_BaseTask
	if is_instance_valid(base_task):
		return base_task
	return null


func _find_child_tasks() -> Array[BT_BaseTask]:
	var tasks: Array[BT_BaseTask] = []
	for node: Node in get_children(false):
		if is_instance_valid(node) and node is BT_BaseTask:
			tasks.push_back(node)
	return tasks


func _assign_behavior_tree() -> void:
	for task: BT_BaseTask in child_tasks:
		task.behavior_tree = behavior_tree


func _update_child_tasks() -> void:
	child_tasks = _find_child_tasks()
