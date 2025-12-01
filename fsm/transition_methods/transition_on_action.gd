@tool
class_name TransitionOnAction
extends StateTransition
## Generic transition state that emits a transition attempt when an action
## is pressed.

@export var transition_actions: Array[StringName] = []:
	set(v):
		transition_actions = v
		update_configuration_warnings()


func _init() -> void:
	if Engine.is_editor_hint():
		return
	state_connected.connect(_setup_state)


func _unhandled_input(event: InputEvent) -> void:
	for action: StringName in transition_actions:
		assert(InputMap.has_action(action), str(
				"Invalid action assigned: %s" % action))

		if event.is_action(action) \
				and is_current_state() \
				and exit_node \
				and is_active_actor():
			parent_state.change_state_node(exit_node)
			set_input_as_handled()


func _check_transition() -> bool:
	return false


func _get_configuration_warnings() -> PackedStringArray:
	InputMap.load_from_project_settings()
	var warnings: Array[String] = []
	for action_str: StringName in transition_actions:
		if not InputMap.has_action(action_str):
			warnings.push_back(action_str + " is an invalid action!")
	if not exit_node:
		warnings.push_back("No exit node set!")
	return warnings


func _setup_state(_new_state: State) -> void:
	pass


func is_active_actor() -> bool:
	var actor_state := parent_state as ActorState
	if actor_state:
		return actor_state.actor == Player.get_actor()
	return false
