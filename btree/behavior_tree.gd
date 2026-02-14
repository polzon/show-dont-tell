@abstract
@icon("res://addons/show_not_tell/icons/tree.svg")
class_name BehaviorTree
extends BT_BaseTask
## BehaviorTree behavior controller that processes various [BT_BaseTask]
## and [Action].

signal changed_task(task: BT_BaseTask)

@export_group("Debug")
@export var print_task_chain: bool = false

## The child task currently being executed.
var current_task: BT_BaseTask:
	set = set_current_task
var process_chain: Array[BT_BaseTask] = []
var running_task: BT_BaseTask


func _process(delta: float) -> void:
	_update_tick(delta)
	if running_task:
		running_task._process_tick(delta)


func _physics_process(delta: float) -> void:
	if running_task:
		running_task._physics_tick(delta)


func _update_tick(delta: float) -> void:
	process_chain.clear()
	status = current_task.execute(delta)
	if status != RUNNING:
		current_task = next_task()
	if print_task_chain:
		_print_process_chain()


func _find_child_tasks() -> Array[BT_BaseTask]:
	var found_tasks := super()
	for task in found_tasks:
		if not current_task:
			current_task = task
		task.behavior_tree = self
	return found_tasks


func set_current_task(new_task: BT_BaseTask) -> void:
	current_task = new_task
	changed_task.emit(current_task)


func handle_action(action: Action) -> void:
	if running_task:
		running_task._handle_action(action)


#region DEBUG
func _print_process_chain() -> void:
	var chain_string: String = ""
	for task in process_chain:
		if not chain_string.is_empty():
			chain_string += " > "
		chain_string += task.name
	print(chain_string)
#endregion DEBUG
