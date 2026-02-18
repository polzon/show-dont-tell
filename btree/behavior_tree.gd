@icon("res://addons/show_not_tell/icons/tree.svg")
class_name BehaviorTree
extends BehaviorTask
## BehaviorTree behavior controller that processes various [BehaviorTask]
## and [Action].

signal changed_task(task: BehaviorTask)
signal active_leaf_changed(leaf: BehaviorTask)

enum TickProcess {
	## [method _tick] is proccessed during [member _physics_process].
	PHYSICS,
	## [method _tick] is proccessed during [member _process].
	PROCESS,
	## [method _tick] is proccessed during [member _process]
	## and [member _physics_process].
	BOTH,
}

@export var enabled: bool = true
## When [method _tick] is processing a [method running_task].
@export var tick_processing := TickProcess.PHYSICS

@export_group("Debug")
@export var print_active_state: bool = false
@export var print_task_chain: bool = false
@export var debug_running_task: bool = false

## The child task currently being executed.
var current_task: BehaviorTask:
	set = set_current_task
var process_chain: Array[BehaviorTask] = []
var running_task: BehaviorTask:
	set = set_running_task

var _last_executed_leaf: BehaviorTask = null:
	set = set_leaf_executed


static func find_behavior_tree(node: Node) -> BehaviorTree:
	for child: Node in node.find_children("", &"BehaviorTree"):
		if child is BehaviorTree:
			return child
	return null


func _process(delta: float) -> void:
	if not enabled:
		return

	if tick_processing != TickProcess.PHYSICS:
		_update_tick(delta)

	if running_task:
		if debug_running_task:
			print("[BehaviorTree] _process_tick: ", running_task.name)
		running_task._process_tick(delta)
		running_task._assert_running_task()
	elif debug_running_task:
		print("[BehaviorTree._process] No running_task set")


func _physics_process(delta: float) -> void:
	if not enabled:
		return

	if tick_processing != TickProcess.PROCESS:
		_update_tick(delta)

	if running_task:
		if debug_running_task:
			print("[BehaviorTree] _physics_tick: ", running_task.name)
		running_task._physics_tick(delta)
		running_task._assert_running_task()
	elif debug_running_task:
		print("[BehaviorTree._physics_process] No running_task set")


func _update_tick(delta: float) -> void:
	process_chain.clear()
	status = current_task.execute(delta)
	if status != RUNNING:
		current_task = next_task()
		current_task._assert_current_task()
	if print_task_chain:
		_print_process_chain()


func _find_child_tasks() -> Array[BehaviorTask]:
	var found_tasks := super()
	for task in found_tasks:
		if not current_task:
			current_task = task
		task.behavior_tree = self
	return found_tasks


func set_running_task(new_task: BehaviorTask) -> void:
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

	else:
		push_warning(
			(
				"[BehaviorTree]: Rejected assigning [%s] already running state: %s"
				% [running_task.name, new_task.name]
			)
		)


func handle_action(action: Action) -> void:
	if running_task:
		running_task._handle_action(action)


func _clear_task() -> void:
	running_task = null


func set_current_task(new_task: BehaviorTask) -> void:
	current_task = new_task
	changed_task.emit(current_task)


func set_leaf_executed(leaf: BehaviorTask) -> void:
	# Track when the active leaf changes and emit signal
	if leaf != _last_executed_leaf:
		_last_executed_leaf = leaf
		active_leaf_changed.emit(leaf)


func _print_process_chain() -> void:
	var chain_string: String = ""
	for task in process_chain:
		if not chain_string.is_empty():
			chain_string += " > "
		chain_string += task.name
	print(chain_string)
