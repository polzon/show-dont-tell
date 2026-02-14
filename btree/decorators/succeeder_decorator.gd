@icon("res://addons/show_not_tell/icons/succeeder.svg")
class_name BT_SucceederDecorator
extends BT_DecoratorTask
## A Succeeder node will always return a SUCCESS status code, no matter the
## outcome of its child node.


func _tick(delta: float) -> Status:
	var child_status: Status = _execute_child(delta)
	return SUCCESS if child_status != RUNNING else RUNNING
