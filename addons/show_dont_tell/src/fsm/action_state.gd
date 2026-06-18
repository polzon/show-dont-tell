class_name ActionState
extends FiniteState

# TODO: This likely will just be refactored back into FiniteState and removed.

signal transitioned_to(state: FiniteState)

@export var action: StateData
@export var transitions: Array[TransitionRule] = []

var _active_transition: TransitionRule


func _ready() -> void:
	_set_transitions(transitions)


func _on_state_start() -> void:
	_active_transition = null


func _on_state_end() -> void:
	transitioned_to.emit(get_valid_transition_exit())


func _tick(delta: float) -> void:
	if action:
		action._process_tick(delta)


func _physics_tick(delta: float) -> void:
	if action:
		action._physics_tick(delta)
	if _can_transition():
		var exit_node := get_valid_transition_exit()
		change_state_node(exit_node)


## Called from [StateMachine] when an command is passed to it,
## but only when it's the [member current_state].
func _handle_command(_command: Command) -> void:
	for transition in transitions:
		transition.handle_command(_command)


func _can_transition() -> bool:
	for transition in transitions:
		if transition.can_transition():
			_active_transition = transition
			return true
	return false


func get_valid_transition_exit() -> FiniteState:
	if _active_transition and not _active_transition.exit_path.is_empty():
		return get_node(_active_transition.exit_path) as FiniteState
	return null


func _set_transitions(new_transitions: Array[TransitionRule]) -> void:
	for transition: TransitionRule in transitions:
		if transitioned_to.is_connected(transition._on_transition):
			transitioned_to.disconnect(transition._on_transition)
	transitions = new_transitions
	for transition: TransitionRule in new_transitions:
		transitioned_to.connect(transition._on_transition)
