@abstract
@icon("res://addons/show_not_tell/icons/tree.svg")
class_name BehaviorTree
extends BehaviorControl
## BehaviorTree behavior controller that processes various [BT_BaseTask]
## and [Action].

const SUCCESS = BT_BaseTask.SUCCESS
const FAILED = BT_BaseTask.FAILED
const RUNNING = BT_BaseTask.RUNNING

signal changed_task(task: BT_BaseTask)
signal task_ended(task: BT_BaseTask)
signal task_started(task: BT_BaseTask)

var current_task: BT_BaseTask:
	set = _set_current_task


func _ready() -> void:
	_assign_behavior_tree()


func _process(delta: float) -> void:
	if is_instance_valid(current_task):
		current_task._process_tick(delta)


func _find_child_tasks() -> Array[BT_BaseTask]:
	var tasks: Array[BT_BaseTask] = []
	for node: Node in get_children():
		var task := node as BT_BaseTask
		if is_instance_valid(task):
			tasks.push_back(task)
	return tasks


func _assign_behavior_tree() -> void:
	for task: BT_BaseTask in _find_child_tasks():
		if not current_task:
			current_task = task
		task.behavior_tree = self


func _set_current_task(new_task: BT_BaseTask) -> void:
	if current_task:
		task_ended.emit(current_task)
	current_task = new_task
	task_started.emit(current_task)
	changed_task.emit(current_task)
