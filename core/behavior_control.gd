@abstract
@icon("res://addons/show_not_tell/icons/tree.svg")
class_name BehaviorControl
extends BaseState
## Abstract control point that BehaviorTree and StateMachine are
## extended from.

# TODO: Figure out how to restructure this, because BehaviorTree doesn't
# actually use this.

signal enabled_toggled

@export var enabled: bool = true:
	set = set_enabled

var _inital_process_mode: ProcessMode
var _has_set_inital_process_mode: bool = false


func set_enabled(is_enabled: bool) -> void:
	enabled = is_enabled
	if not _has_set_inital_process_mode:
		_inital_process_mode = process_mode
		_has_set_inital_process_mode = true
	process_mode = (
		_inital_process_mode if is_enabled else Node.PROCESS_MODE_DISABLED
	)
	enabled_toggled.emit()


@abstract func handle_action(action: Action) -> void
