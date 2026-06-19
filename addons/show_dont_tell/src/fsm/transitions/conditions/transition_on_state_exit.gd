@tool
class_name TransitionOnStateExit
extends TransitionOnCondition

var _parent_state: FiniteState:
	get = _get_parent_state
var _has_exited: bool = false


func _get_parent_state() -> FiniteState:
	if not _parent_state and _parent:
		_parent_state = _parent.get_parent() as FiniteState
		_parent_state.state_ended.connect(_on_parent_state_exit)
	return _parent_state


func _on_parent_state_exit() -> void:
	_has_exited = true


func _can_transition() -> bool:
	if _parent_state:
		return _has_exited
	return false


func _get_friendly_name() -> String:
	return "OnStateExit"
