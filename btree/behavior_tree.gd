@abstract
@icon("res://addons/show_not_tell/icons/tree.svg")
class_name BehaviorTree
extends BT_BaseTask
## BehaviorTree behavior controller that processes various [BT_BaseTask]
## and [Action].

signal changed_task(task: BT_BaseTask)

enum TickProcess {
	## [method _tick] is proccessed during [member _physics_process].
	PHYSICS,
	## [method _tick] is proccessed during [member _process].
	PROCESS,
}

@export var enabled: bool = true
## When [method _tick] is processing a [method running_task].
@export var tick_processing := TickProcess.PHYSICS

@export_group("Debug")
@export var print_active_state: bool = false
@export var print_task_chain: bool = false
@export var debug_running_task: bool = false

## The child task currently being executed.
var current_task: BT_BaseTask:
	set = set_current_task
var process_chain: Array[BT_BaseTask] = []
var running_task: BT_BaseTask:
	set = set_running_task


func _process(delta: float) -> void:
	if not enabled:
		return

	if tick_processing == TickProcess.PROCESS:
		_update_tick(delta)

	if running_task:
		if debug_running_task:
			print("[BehaviorTree] _process_tick: ", running_task.name)
		running_task._process_tick(delta)
	elif debug_running_task:
		print("[BehaviorTree._process] No running_task set")


func _physics_process(delta: float) -> void:
	if not enabled:
		return

	if tick_processing == TickProcess.PHYSICS:
		_update_tick(delta)

	if running_task:
		if debug_running_task:
			print("[BehaviorTree] _physics_tick: ", running_task.name)
		running_task._physics_tick(delta)
	elif debug_running_task:
		print("[BehaviorTree._physics_process] No running_task set")


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


func set_running_task(new_task: BT_BaseTask) -> void:
	if not new_task:
		if running_task:
			running_task.task_ended.disconnect(_clear_task)
		running_task = null
		if print_active_state or debug_running_task:
			print("[BehaviorTree]: Cleared running state.")

	elif new_task != running_task:
		# Allow switching from one task to another
		if running_task:
			running_task.task_ended.disconnect(_clear_task)

		running_task = new_task
		running_task.task_ended.connect(_clear_task)
		if print_active_state or debug_running_task:
			print("[BehaviorTree]: Set running state: %s." % running_task.name)


func handle_action(action: Action) -> void:
	if running_task:
		running_task._handle_action(action)


func _clear_task() -> void:
	running_task = null


func _print_process_chain() -> void:
	var chain_string: String = ""
	for task in process_chain:
		if not chain_string.is_empty():
			chain_string += " > "
		chain_string += task.name
	print(chain_string)
