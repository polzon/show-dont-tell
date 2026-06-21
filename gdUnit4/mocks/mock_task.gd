class_name MockTask
extends BehaviorTask
## Generic Mock [BehaviorTask] for testing [BehaviorTree]
## composites and decorators.
##
## Can be configured to return any status, track execution, and simulate
## various scenarios for testing task behavior.

# ? Consider if we can remove this and use mock() in unit tests instead.

var was_executed: bool = false
var execution_count: int = 0
var configured_status: Status = SUCCESS
var child_was_called: bool = false
var handle_command_was_called: bool = false
var last_action_received: Command = null


func _tick(_delta: float) -> Status:
	was_executed = true
	execution_count += 1
	return configured_status


func execute(delta: float) -> Status:
	child_was_called = true
	return super.execute(delta)


func _handle_command(command: Command) -> void:
	handle_command_was_called = true
	last_action_received = command
	super._handle_command(command)


func set_return_status(new_status: Status) -> void:
	configured_status = new_status


func reset() -> void:
	was_executed = false
	execution_count = 0
	child_was_called = false
	handle_command_was_called = false
	last_action_received = null
