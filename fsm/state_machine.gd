@icon("res://addons/show_not_tell/icons/tree.svg")
class_name StateMachine
extends FiniteState
## Implementation of a FiniteStateMachine.

signal enabled_toggled
## Emits after [signal state_end] when the previous state
## is finished.
signal state_start(started_state: FiniteState)
## Emits before [signal state_start] when the previous state
## is finished.
signal state_end(end_state: FiniteState)

@export var enabled: bool = true:
	set = set_enabled

## Current [FiniteState] the parent node is in.
var state: FiniteState:
	set = set_state
## The previous [Action] that was called through [method handle_action].
var current_action: Action

var _inital_process_mode: ProcessMode
var _has_set_inital_process_mode: bool = false


static func find_state_machine(node: Node) -> StateMachine:
	for child: Node in node.find_children("", &"StateMachine"):
		if child is StateMachine:
			return child
	return null


## Finds the state as a [GDScript], assuming it's already a node that
## exists under this StateMachine node. It allows for clean syntax,
## like get_state(StateMove).
func get_state(state_type: GDScript) -> FiniteState:
	for node: Node in get_children():
		var state_node := node as FiniteState
		assert(state_node, "Key Object is null.")
		if is_instance_of(state_node, state_type):
			return state_node

	printerr("Couldn't find FiniteState: ", state_type.get_global_name())
	return null


func _init() -> void:
	enabled_toggled.connect(_on_enabled_toggled)


func _ready() -> void:
	if not state:
		push_warning("No initial state set!")
	assert(get_parent() or not is_inside_tree(), "StateMachine is an orphan?")


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		set_process(false)
	elif state:
		state._tick(delta)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
	elif state:
		state._physics_tick(delta)


## Passes the [Action] to the current [FiniteState], as well as sets
## [member current_action] to the submitted action.
func _action_process(action: Action) -> void:
	current_action = action
	if is_instance_valid(state):
		state._handle_action(action)


func _on_enabled_toggled() -> void:
	set_process(enabled)
	set_physics_process(enabled)


func set_state(new_state: FiniteState) -> void:
	if state and not Engine.is_editor_hint():
		state._on_state_end()
		state_end.emit(state)
	state = new_state
	if state and not Engine.is_editor_hint():
		state._on_state_start()
		state_start.emit(state)


func handle_action(action: Action) -> void:
	if enabled:
		_action_process(action)


## Interrupts and immediately changes the current [FiniteState].
## If wanting to wait for the state to finish instead, use [method queue_state].
func change_state(new_state: GDScript) -> void:
	var state_node := get_state(new_state)
	change_state_node(state_node)


func change_state_node(state_node: FiniteState) -> void:
	if is_instance_valid(state_node):
		state = state_node


func set_enabled(is_enabled: bool) -> void:
	enabled = is_enabled
	if not _has_set_inital_process_mode:
		_inital_process_mode = process_mode
		_has_set_inital_process_mode = true
	process_mode = (
		_inital_process_mode if is_enabled else Node.PROCESS_MODE_DISABLED
	)
	enabled_toggled.emit()
