@tool
@abstract
@icon("uid://eq0sp4g3s75r")
class_name TransitionOnCondition
extends Resource
## Base class for conditional logic on if a FiniteState transition can occur.

@export var invert_condition: bool = false:
	set(v):
		invert_condition = v
		changed.emit()


func tick_transition() -> bool:
	return not _can_transition() if invert_condition else _can_transition()


## Checks if a transition can be performed.
@abstract func _can_transition() -> bool


## Optional override for [TransitionCondition] auto-generated friendly name.
func _get_friendly_name() -> String:
	return ""


## Optional function for TransitionMethod to check any potential issues.
func _configuration_warning() -> PackedStringArray:
	return []
