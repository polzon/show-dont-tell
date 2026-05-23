class_name MockCommandLeaf
extends BT_CommandLeaf
## Mock [BT_CommandLeaf] for testing [BehaviorTree] command execution.
##
## Tracks execution and allows configuration of return status.

var was_executed: bool = false
var execution_count: int = 0
var configured_status: Status = SUCCESS
var execution_duration: float = 0.0


func _tick(delta: float) -> Status:
	was_executed = true
	execution_count += 1
	execution_duration += delta
	return configured_status


func set_return_status(new_status: Status) -> void:
	configured_status = new_status


func reset() -> void:
	was_executed = false
	execution_count = 0
	execution_duration = 0.0
