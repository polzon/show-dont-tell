@icon("res://addons/show_not_tell/icons/limiter.svg")
class_name BT_LimiterDecorator
extends BT_DecoratorTask
## The Limiter node executes its RUNNING child a specified number of
## times (x).
##
## When the maximum number of ticks is reached, it
## returns a FAILURE status code. The limiter resets its counter
## after its child returns either SUCCESS or FAILURE.


func _tick(_delta: float) -> Status:
	return Status.FAILED
