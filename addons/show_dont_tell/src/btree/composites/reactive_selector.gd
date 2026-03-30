@icon("res://addons/show_not_tell/icons/selector_reactive.svg")
class_name BT_ReactiveSelector
extends BT_SelectorComposite
## Reactive selector composite.
##
## Ticks children from left to right every frame, always starting at the first
## child. Returns SUCCESS on the first child success, RUNNING on the first child
## still running, and FAILED only if all children fail.


func _tick(delta: float) -> Status:
	for child in child_tasks:
		var child_status: Status = child.execute(delta)

		if child_status == SUCCESS:
			return SUCCESS
		if child_status == RUNNING:
			return RUNNING

	return FAILED
