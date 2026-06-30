@tool
class_name TransitionOnStateExit
extends TransitionOnCondition

@export_group("Debug")
@export var warn_on_multiple_requests: bool = false

var _parent_state: FiniteState:
	get = _get_parent_state
var _requests_exit: bool = false


func _ready() -> void:
	assert(_parent_state, "TransitionOnStateExit: No parent FiniteState found.")
	if not _parent_state or Engine.is_editor_hint():
		return

	_parent_state.state_started.connect(_on_state_entered)
	var state_data := _parent_state.state_data
	if state_data:
		state_data.state_timeout.connect(request_transition.emit)
		state_data.state_timeout.connect(_on_state_data_exit)


func _get_parent_state() -> FiniteState:
	if not _parent_state and _parent and _parent.get_parent() is FiniteState:
		_parent_state = _parent.get_parent()
	return _parent_state


func _on_state_data_exit() -> void:
	if _requests_exit and warn_on_multiple_requests:
		var state_name := _parent_state.name if _parent_state else &"Unknown"
		push_warning(
			"TransitionOnStateExit: Multiple exit requests for %s" % state_name
		)
	_requests_exit = true


func _on_state_entered() -> void:
	_requests_exit = false


func _can_transition() -> bool:
	if _parent_state:
		return _requests_exit
	return false


func _get_friendly_name() -> String:
	return "OnStateExit"
