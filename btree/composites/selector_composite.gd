@abstract
@icon("res://addons/show_not_tell/icons/selector.svg")
class_name BT_SelectorComposite
extends BT_CompositeTask
## The Selector node is another fundamental building block in Behavior Trees,
## used to manage decision-making among multiple child nodes.
## It helps you define different behaviors for your game characters or
## objects based on varying conditions.
##
## The Selector node tries to execute each of its children one by one,
## in the order they are connected. It reports a SUCCESS status code if any
## child reports a SUCCESS. If all children report a FAILURE status code,
## the Selector node also returns FAILURE.
##
## @tutorial(Beehave Reference): https://bitbra.in/beehave/#/manual/selector


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
		if child_status == SUCCESS:
			return SUCCESS

		current_child_index += 1

	return FAILED
