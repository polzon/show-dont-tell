@icon("res://addons/show_not_tell/icons/inverter.svg")
class_name BT_InverterDecorator
extends BT_DecoratorTask
## An Inverter node reverses the outcome of its child node. It returns
## FAILURE if its child returns a SUCCESS status code, and SUCCESS if
## its child returns a FAILURE status code.


func _tick(delta: float) -> Status:
	var child_status: Status = _execute_child(delta)
	match child_status:
		SUCCESS:
			return FAILED
		FAILED:
			return SUCCESS
		_:
			return RUNNING
