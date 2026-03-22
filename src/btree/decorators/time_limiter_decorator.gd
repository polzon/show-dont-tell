@icon("res://addons/show_not_tell/icons/limiter.svg")
class_name BT_TimeLimiterDecorator
extends BT_DecoratorTask
## The TimeLimiter node only gives its RUNNING child a set amount of time
## to finish.
##
## When the time is up, it interrupts its child and returns
## a FAILURE status code. The time limiter resets its time after
## its child returns either SUCCESS or FAILURE.

@export var time_limit: float = 5.0

var elapsed_time: float = 0.0


func _reset() -> void:
	elapsed_time = 0.0


func _entered_state() -> void:
	_reset()
	super._entered_state()


func _exited_state() -> void:
	_reset()
	super._exited_state()


func _tick(delta: float) -> Status:
	if not _get_child_task():
		return FAILED

	elapsed_time += delta

	if elapsed_time >= time_limit:
		return FAILED

	return _execute_child(delta)
