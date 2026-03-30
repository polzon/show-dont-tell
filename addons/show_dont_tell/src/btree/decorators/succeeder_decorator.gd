@icon("res://addons/show_not_tell/icons/succeeder.svg")
class_name BT_SucceederDecorator
extends BT_DecoratorTask
## A Succeeder node converts FAILURE to SUCCESS. If the child returns
## RUNNING or SUCCESS, those statuses are passed through unchanged.


func _tick(delta: float) -> Status:
	var child_status: Status = _execute_child(delta)
	return SUCCESS if child_status != RUNNING else RUNNING
