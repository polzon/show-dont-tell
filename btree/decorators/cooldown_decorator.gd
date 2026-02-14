@icon("res://addons/show_not_tell/icons/cooldown.svg")
class_name BT_CooldownDecorator
extends BT_DecoratorTask
## The Cooldown node executes its child until it either returns SUCCESS
## or FAILURE, after which it will start an internal timer and return
## FAILURE until the timer is complete. The cooldown is then able
## to execute its child again.

@export var cooldown_duration: float = 1.0

var last_execution_time: float = - INF


func _tick(delta: float) -> Status:
	var current_time: float = Time.get_ticks_msec() / 1000.0

	if current_time - last_execution_time < cooldown_duration:
		return FAILED

	var child_status: Status = _execute_child(delta)

	if child_status != RUNNING:
		last_execution_time = current_time

	return child_status
