@abstract
@icon("res://addons/show_not_tell/icons/sequence.svg")
class_name BT_SequenceComposite
extends BT_CompositeTask
## The Sequence node is a fundamental building block in Behavior Trees,
## used to execute a series of child nodes in a specific order. It helps
## you define the order of actions or tasks that your game characters
## or objects will follow.
##
## The Sequence node tries to execute all its children one by one, in the
## order they are connected. It reports a SUCCESS status code if all
## children report SUCCESS. If at least one child reports a FAILURE
## status code, the Sequence node also returns FAILURE.
##
## @tutorial(Beehave Reference): https://bitbra.in/beehave/#/manual/sequence


func _entered_state() -> void:
	_reset_child_index()
	super._entered_state()


func _exited_state() -> void:
	_reset_child_index()
	super._exited_state()


func _tick(delta: float) -> Status:
	while current_child_index < child_tasks.size():
		var child: BT_BaseTask = child_tasks[current_child_index]
		var child_status: Status = child.execute(delta)

		if child_status == RUNNING:
			return RUNNING
		elif child_status == FAILED:
			return FAILED

		current_child_index += 1

	return SUCCESS
