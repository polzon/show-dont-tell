class_name MockBaseTask
extends BehaviorTask
## Mock [BehaviorTask] for testing task behavior in isolation.

var tick_count: int = 0
var tick_delta_sum: float = 0.0


func _tick(delta: float) -> Status:
	tick_count += 1
	tick_delta_sum += delta
	return Status.SUCCESS
