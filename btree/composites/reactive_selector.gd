@icon("res://addons/show_not_tell/icons/selector_reactive.svg")
class_name BT_ReactiveSelector
extends BT_SelectorComposite


func _tick(delta: float) -> Status:
	for child in child_tasks:
		var child_status: Status = child.execute(delta)

		if child_status == SUCCESS:
			return SUCCESS
		elif child_status == RUNNING:
			return RUNNING

	return FAILED
