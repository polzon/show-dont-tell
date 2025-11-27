class_name StateMachine
extends BehaviorControl
## Implemntation of a Finite State Machine.

# TODO: There are still instances of [Actor] left over in [State] that I need
#       to remove for this addon to remain portable.

## Emits after [signal state_end] when the previous state
## is finished.
signal state_start(started_state: State)
## Emits before [signal state_start] when the previous state
## is finished.
signal state_end(end_state: State)

var _process_usec: int = 0
var _physics_usec: int = 0
var _action_usec: int = 0

## Current [State] the actor is in.
var state: State:
	set = _set_state
## The previous [Action] that was called through [method handle_action].
var current_action: Action

@export_group("Performance Warnings")

## If enabled, each [State] tick is measured for it's elapsed run duration.
## [member _physics_tick] and [member _tick] are measured seperately.
## If elapsed duration lasts longer then the configured warning threshold,
## a warning will be pushed. This can help detect performance issues early on.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "")
var performance_warning_enabled: bool = false:
	get():
		if not OS.is_debug_build():
			return false
		return performance_warning_enabled
## The elapsed time threshold in micro-seconds that a function should take to
## run before triggering a warning.
@export_range(1, 10000) var performance_warning_threshold: int = 1000


## Finds the state as a [GDScript], assuming it's already a node that
## exists under this StateMachine node. It allows for clean syntax,
## like get_state(StateMove).
func get_state(state_type: GDScript) -> State:
	for node: Node in get_children():
		var state_node := node as State
		assert(state_node, "Passed gdscript is not a State object!")
		if state_node \
				and is_instance_of(state_node, state_type):
			return state_node

	printerr("Couldn't find State: ", state_type.get_global_name())
	return null


func _ready() -> void:
	if not state:
		push_warning("No inital state set!")


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		set_process(false)

	elif is_instance_valid(state):
		if performance_warning_enabled:
			_process_usec = Time.get_ticks_usec()
			state._tick(delta)
			_process_usec = Time.get_ticks_usec() - _process_usec
			_measure_performance()
		else:
			state._tick(delta)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)

	elif is_instance_valid(state):
		if performance_warning_enabled:
			_physics_usec = Time.get_ticks_usec()
			state._physics_tick(delta)
			_physics_usec = Time.get_ticks_usec() - _physics_usec
		else:
			state._physics_tick(delta)


## Passes the [Action] to the current [State], as well as sets
## [member current_action] to the submitted action.
func _action_process(action: Action) -> void:
	current_action = action
	if is_instance_valid(state):
		state._handle_action(action)


func _measure_performance() -> void:
	if not performance_warning_enabled or not current_action:
		return

	var action_script: Script = current_action.get_script()
	var script_name := action_script.get_global_name()
	var actor_name: String = \
			str(current_action.actor.name) \
			if is_instance_valid(current_action.actor) \
			else str(current_action.actor)

	var warning_prefix := "%s/%s:" % [actor_name, script_name]
	if _process_usec >= performance_warning_threshold:
		push_warning("%s Process tick elapsed %s usecs." \
				% [warning_prefix, _process_usec])
	if _physics_usec >= performance_warning_threshold:
		push_warning("%s Physics tick elapsed %s usecs." \
				% [warning_prefix, _physics_usec])
	if _action_usec >= performance_warning_threshold:
		push_warning("%s Action processed in %s usecs." \
				% [warning_prefix, _action_usec])


func _set_state(new_state: State) -> void:
	if state and not Engine.is_editor_hint():
		state._on_state_end()
		state_end.emit(state)
	state = new_state
	if state and not Engine.is_editor_hint():
		state._on_state_start()
		state_start.emit(state)


func handle_action(action: Action) -> void:
	_action_usec = Time.get_ticks_usec()
	_action_process(action)
	_action_usec = Time.get_ticks_usec() - _action_usec


## Interrupts and immediately changes the current [State].
## If wanting to wait for the state to finish instead, use [method queue_state].
func change_state(new_state: GDScript) -> void:
	var state_node := get_state(new_state)
	if state_node:
		state = state_node
