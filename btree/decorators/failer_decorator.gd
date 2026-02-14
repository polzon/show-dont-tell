@icon("res://addons/show_not_tell/icons/failer.svg")
class_name BT_FailerDecorator
extends BT_DecoratorTask
## A Failer node will always return a FAILURE status code, regardless of
## the result of its child node.


func _tick(delta: float) -> Status:
	var child_status: Status = _execute_child(delta)
	return FAILED if child_status != RUNNING else RUNNING
