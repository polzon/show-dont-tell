@icon("res://addons/show_not_tell/icons/selector.svg")
class_name BT_ProcessingSelector
extends BT_SelectorComposite
## Selector that re-evaluates children each frame and returns their status
## (SUCCESS/FAILED), preventing tree lock while allowing sibling branches
## to be evaluated.
##
## Unlike a standard Selector that stays in RUNNING once a child returns
## RUNNING, this returns the child's actual status. This allows parent
## sequences to continue re-evaluating siblings (like roll interrupts) every
## frame, while the behavior tree's running_task mechanism provides
## continuous physics/process updates to the active leaf.
##
## Maintains active_child and interrupts it when a different leaf executes,
## ensuring clean state transitions.

@export var debug_print: bool = false

var _active_child: BehaviorTask = null:
	set = _set_active_child


func _tick(delta: float) -> Status:
	# Evaluate all children to detect if any is running.
	var has_running_child: bool = false

	for child: BehaviorTask in child_tasks:
		var child_status: Status = child.execute(delta)

		if child_status == RUNNING:
			_active_child = child
			has_running_child = true
			if debug_print:
				print("[BT_ProcessingSelector] Active child: ", child.name)
			break

	# Return SUCCESS if any child is running, FAILED otherwise.
	return SUCCESS if has_running_child else FAILED


func _set_active_child(child: BehaviorTask) -> void:
	if _active_child == child:
		return
	if _active_child:
		_active_child.interrupt()

	_active_child = child
	if child and is_instance_valid(behavior_tree):
		if not behavior_tree.active_leaf_changed.is_connected(
			_on_active_leaf_changed
		):
			behavior_tree.active_leaf_changed.connect(
				_on_active_leaf_changed, CONNECT_ONE_SHOT
			)


func _on_active_leaf_changed(leaf: BehaviorTask) -> void:
	# If the active leaf is not our child, interrupt our stored child
	if not child_tasks.has(leaf):
		if _active_child:
			_active_child = null
			if debug_print:
				print(
					"[BT_ProcessingSelector] Interrupting active child due",
					" to leaf change: ",
					leaf.name
				)
