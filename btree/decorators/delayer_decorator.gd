@icon("res://addons/show_not_tell/icons/delayer.svg")
class_name BT_DelayerDecorator
extends BT_DecoratorTask
## When first executing the Delayer node, it will start an internal timer
## and return RUNNING until the timer is complete, after which it will
## execute its child node. The delayer resets its time after its
## child returns either SUCCESS or FAILURE.

@export var delay_duration: float = 1.0

var elapsed_time: float = 0.0
var has_delayed: bool = false


func _reset() -> void:
	elapsed_time = 0.0
	has_delayed = false


func _entered_state() -> void:
	_reset()
	super._entered_state()


func _exited_state() -> void:
	_reset()
	super._exited_state()


func _tick(delta: float) -> Status:
	if not _get_child_task():
		return FAILED

	if not has_delayed:
		elapsed_time += delta
		if elapsed_time < delay_duration:
			return RUNNING
		has_delayed = true

	return _execute_child(delta)
