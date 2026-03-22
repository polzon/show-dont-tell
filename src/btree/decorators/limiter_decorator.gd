@icon("res://addons/show_not_tell/icons/limiter.svg")
class_name BT_LimiterDecorator
extends BT_DecoratorTask
## The Limiter node executes its RUNNING child a specified number of
## times (x).
##
## When the maximum number of ticks is reached, it
## returns a FAILURE status code. The limiter resets its counter
## after its child returns either SUCCESS or FAILURE.

@export var max_executions: int = 3

var execution_count: int = 0


func _entered_state() -> void:
	execution_count = 0
	super._entered_state()


func _tick(delta: float) -> Status:
	if execution_count >= max_executions:
		return FAILED

	var child_status: Status = _execute_child(delta)

	if child_status != RUNNING:
		execution_count += 1

	return child_status
