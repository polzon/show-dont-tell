@icon("res://addons/show_not_tell/icons/sequence_reactive.svg")
class_name BT_ReactiveSequence
extends BT_SequenceComposite


func _tick(delta: float) -> Status:
	for child in child_tasks:
		var child_status: Status = child.execute(delta)

		if child_status == FAILED:
			return FAILED
		if child_status == RUNNING:
			return RUNNING

	return SUCCESS
