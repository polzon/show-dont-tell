@icon("res://addons/show_not_tell/icons/sequence_reactive.svg")
class_name BT_ReactiveSequence
extends BT_SequenceComposite
## Reactive sequence composite.
##
## Ticks children from left to right every frame, always starting at the first
## child. Returns FAILED on the first child failure, RUNNING on the first child
## still running, and SUCCESS only if all children succeed.
##
## @tutorial(Beehave Reference): https://bitbra.in/beehave/#/manual/selector


func _tick(delta: float) -> Status:
	for child in child_tasks:
		var child_status: Status = child.execute(delta)

		if child_status == FAILED:
			return FAILED
		if child_status == RUNNING:
			return RUNNING

	return SUCCESS
