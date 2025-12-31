@abstract
@icon("res://addons/show_not_tell/icons/category_bt.svg")
class_name BT_BaseTask
extends Node
## The core of a [BehaviorTree] task that everything is extended from.

const Status = BehaviorTree.Status

const FAILED = Status.FAILED
const SUCCESS = Status.SUCCESS
const RUNNING = Status.RUNNING

var parent_task: BT_BaseTask:
	set = set_parent_task,
	get = get_parent_task

@onready var child_tasks: Array[BT_BaseTask] = []:
	get = get_child_tasks


func _enter_tree() -> void:
	if not child_order_changed.is_connected(_update_child_tasks):
		child_order_changed.connect(_update_child_tasks)
	_update_child_tasks()


func _exit_tree() -> void:
	if child_order_changed.is_connected(_update_child_tasks):
		child_order_changed.disconnect(_update_child_tasks)


@abstract
## Tick process that every node runs. Must return a [Status] value.
func _tick() -> Status

## Base process tick function that is triggered every [BehaviorTree]
## process updates. This function updates every possible frame.
func _process_tick() -> Status:
	return FAILED


## Base physics tick function that is triggered every [BehaviorTree]
## physics update. This function updates every physics update.
func _physics_tick() -> Status:
	return FAILED


func get_parent_task() -> BT_BaseTask:
	if not parent_task:
		var base_task := get_parent() as BT_BaseTask
		if base_task:
			parent_task = base_task
	return parent_task


func set_parent_task(task: BT_BaseTask) -> void:
	parent_task = task


func get_child_tasks() -> Array[BT_BaseTask]:
	return child_tasks


func _update_child_tasks() -> void:
	child_tasks.clear()
	for node: Node in get_children(false):
		if is_instance_valid(node) and node is BT_BaseTask:
			child_tasks.push_back(node)
