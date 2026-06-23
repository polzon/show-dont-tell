@tool
class_name TransitionOnAction
extends TransitionOnCondition
## Transition rule that triggers when a movement command is received.

enum ActionMethod {
	IS_PRESSED,
	IS_JUST_PRESSED,
	IS_JUST_RELEASED,
}

@export_custom(PROPERTY_HINT_INPUT_NAME, "") var trigger_action: StringName:
	set(v):
		trigger_action = v
		changed.emit()
@export var action_method: ActionMethod = ActionMethod.IS_PRESSED:
	set(v):
		action_method = v
		changed.emit()


func _can_transition() -> bool:
	if InputMap.has_action(trigger_action):
		if (
			(
				action_method == ActionMethod.IS_PRESSED
				and Input.is_action_pressed(trigger_action)
			)
			or (
				action_method == ActionMethod.IS_JUST_PRESSED
				and Input.is_action_just_pressed(trigger_action)
			)
			or (
				action_method == ActionMethod.IS_JUST_RELEASED
				and Input.is_action_just_released(trigger_action)
			)
		):
			return true
	return false


func _get_friendly_name() -> String:
	if trigger_action != "":
		var action_method_str: String = ActionMethod.find_key(action_method)
		return (
			"%s %s"
			% [
				trigger_action.to_pascal_case(),
				action_method_str.to_pascal_case()
			]
		)
	return ""
