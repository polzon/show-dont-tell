@abstract
class_name BehaviorTree
extends BehaviorControl
## BehaviorTree behavior controller that processes various [BT_BaseTask]
## and [Action].

signal changed_task(task: BT_BaseTask)
signal task_ended(task: BT_BaseTask)
signal task_started(task: BT_BaseTask)

const Status = BT_BaseTask.Status

var current_task: BT_BaseTask:
	set = _set_current_task

@export_group("Debug")
@export var print_state_changes: bool = false:
	set(v):
		print("state changes: ", v)
		print_state_changes = v


func _ready() -> void:
	if print_state_changes:
		_connect_debug_state_changes()
		print("Actor Behavior Tree init.")
	_assign_behavior_tree()


func _process(delta: float) -> void:
	_process_tick(delta)


func _process_tick(delta: float) -> Status:
	if is_instance_valid(current_task):
		var result := current_task._process_tick(delta)
		match current_task:
			Status.SUCCESS:
				pass
			Status.FAILED:
				pass
			Status.RUNNING:
				pass
		if print_state_changes:
			print("task %s result: %s"
					% [current_task, Status.find_key(result)])
	return Status.SUCCESS


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
		current_task._on_task_end()
		task_ended.emit(current_task)
	current_task = new_task
	current_task._on_task_start()
	task_started.emit(current_task)
	changed_task.emit(current_task)


#region DEBUG
func _connect_debug_state_changes() -> void:
	changed_task.connect(_print_change_task)
	task_started.connect(_print_task_stared)
	task_ended.connect(_print_task_ended)


func _print_change_task(task: BT_BaseTask) -> void:
	print("Changed to task: ", task)


func _print_task_stared(task: BT_BaseTask) -> void:
	print("Task started: ", task)


func _print_task_ended(task: BT_BaseTask) -> void:
	print("Task ended: ", task)
#endregion DEBUG
