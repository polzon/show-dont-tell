@abstract
@icon("uid://eq0sp4g3s75r")
class_name TransitionOnCondition
extends Resource
## Base class for conditional logic on if a FiniteState transition can occur.

signal request_transition

@export var invert_condition: bool = false:
	set(v):
		invert_condition = v
		changed.emit()

var _parent: TransitionCondition


## Called from [TransitionCondition] when the node is ready.
## [br] This is a public method and [b]should not[/b] be overridden.
## Please use [method _ready] instead.
func ready() -> void:
	_ready()


## Called when the [TransitionNode] containing this script is ready.
func _ready() -> void:
	pass


func register_parent(parent_transition: TransitionCondition) -> void:
	_parent = parent_transition


## Handles a command passed to this condition.
func handle_command(_command: Command) -> bool:
	return false


## Runs the per-frame hook for this condition.
func process_tick(delta: float) -> void:
	_process_tick(delta)


## Runs the fixed-step hook for this condition.
func physics_tick(delta: float) -> void:
	_physics_tick(delta)


## Runs immediately before this condition's transition.
func before_transition() -> void:
	_before_transition()


## Inner hook for per-frame condition work.
func _process_tick(_delta: float) -> void:
	pass


## Inner hook for fixed-step condition work.
func _physics_tick(_delta: float) -> void:
	pass


## Inner hook for work before this condition's transition.
func _before_transition() -> void:
	pass


## Returns whether this condition can trigger its transition.
func tick_transition() -> bool:
	return not _can_transition() if invert_condition else _can_transition()


## Checks if a transition can be performed.
@abstract func _can_transition() -> bool


func _request_transition() -> void:
	request_transition.emit()


func _find_transition_exit() -> TransitionExit:
	if not _parent:
		return null

	for child in _parent.find_children("", &"TransitionExit", true, false):
		if child is TransitionExit:
			return child as TransitionExit
	return null


func _find_parent_finite_state() -> FiniteState:
	if not _parent:
		return null

	var parent_node := _parent.get_parent()
	while parent_node != null:
		if parent_node is FiniteState:
			return parent_node as FiniteState
		parent_node = parent_node.get_parent()
	return null


func _find_parent_finite_state_data() -> StateData:
	var parent_state := _find_parent_finite_state()
	if parent_state:
		return parent_state.state_data
	return null


## Optional override for [TransitionCondition] auto-generated friendly name.
func _get_friendly_name() -> String:
	return ""


## Optional function for TransitionMethod to check any potential issues.
func _configuration_warning() -> PackedStringArray:
	return []
