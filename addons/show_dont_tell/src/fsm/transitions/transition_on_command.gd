@tool
class_name TransitionOnCommand
extends StateTransition
## Generic transition state that emits a transition attempt when a command
## is pressed.

@export var transition_commands: Array[StringName] = []:
	set(v):
		transition_commands = v
		update_configuration_warnings()


func _init() -> void:
	if Engine.is_editor_hint():
		return
	state_connected.connect(_setup_state)


func _unhandled_input(event: InputEvent) -> void:
	for command: StringName in transition_commands:
		assert(
			InputMap.has_action(command),
			str("Invalid command assigned: %s" % command)
		)

		if (
			event.is_action(command)
			and is_current_state()
			and exit_node
			and is_active_actor()
		):
			parent_state.change_state_node(exit_node)
			set_input_as_handled()


func _check_transition() -> bool:
	return false


func _get_configuration_warnings() -> PackedStringArray:
	InputMap.load_from_project_settings()
	var warnings: Array[String] = []
	for action_str: StringName in transition_commands:
		if not InputMap.has_action(action_str):
			warnings.push_back(action_str + " is an invalid command!")
	if not exit_node:
		warnings.push_back("No exit node set!")
	return warnings


func _setup_state(_new_state: FiniteState) -> void:
	pass


func is_active_actor() -> bool:
	var actor_state := parent_state as ActorState
	if actor_state:
		return actor_state.actor == Player.get_actor()
	return false
