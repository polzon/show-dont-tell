@abstract
@icon("res://addons/show_not_tell/icons/tree.svg")
class_name BehaviorControl
extends BaseState
## Abstract control point that BehaviorTree and StateMachine are
## extended from.

signal enabled_toggled

@export var enabled: bool = true:
	set = set_enabled


func set_enabled(is_enabled: bool) -> void:
	enabled = is_enabled
	enabled_toggled.emit()


@abstract
func handle_action(action: Action) -> void
