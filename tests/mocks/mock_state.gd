class_name MockState
extends FiniteState
## Mock [FiniteState] for testing [StateMachine] behavior.

# ? Consider changing FiniteState to a non-abstract class.

var tick_called: bool = false
var physics_tick_called: bool = false
var handle_command_called: bool = false


func _tick(_delta: float) -> void:
	tick_called = true


func _physics_tick(_delta: float) -> void:
	physics_tick_called = true


func _handle_command(_command: Variant) -> void:
	handle_command_called = true


func reset_tracking() -> void:
	tick_called = false
	physics_tick_called = false
	handle_command_called = false
