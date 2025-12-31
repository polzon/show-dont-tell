@icon("res://addons/show_not_tell/icons/failer.svg")
class_name BT_FailerDecorator
extends BT_DecoratorTask
## A Failer node will always return a FAILURE status code, regardless of
## the result of its child node.


func _process_tick(_delta: float) -> Status:
	return Status.FAILED
