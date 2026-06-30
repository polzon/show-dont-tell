class_name MockState
extends FiniteState
## Mock [FiniteState] for testing [StateMachine] behavior.

var tick_called: bool = false
var tick_call_count: int = 0

var physics_tick_called: bool = false
var physics_tick_call_count: int = 0

var handle_command_called: bool = false
var handle_command_call_count: int = 0
var last_command: Command


func _tick(delta: float) -> void:
	tick_called = true
	tick_call_count += 1
	super._tick(delta)


func _physics_tick(delta: float) -> void:
	physics_tick_called = true
	physics_tick_call_count += 1
	super._physics_tick(delta)


func _handle_command(command: Command) -> void:
	last_command = command
	if command:
		handle_command_called = true
		handle_command_call_count += 1
	super._handle_command(command)


func reset_tracking() -> void:
	tick_called = false
	tick_call_count = 0
	physics_tick_called = false
	physics_tick_call_count = 0
	handle_command_called = false
	handle_command_call_count = 0
	last_command = null
