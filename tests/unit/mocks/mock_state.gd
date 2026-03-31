class_name MockState
extends FiniteState
## Mock State for testing State behavior.

var tick_called: bool = false
var physics_tick_called: bool = false
var handle_action_called: bool = false


func _tick(_delta: float) -> void:
	tick_called = true


func _physics_tick(_delta: float) -> void:
	physics_tick_called = true


func _handle_action(_action: Variant) -> void:
	handle_action_called = true


func reset_tracking() -> void:
	tick_called = false
	physics_tick_called = false
	handle_action_called = false
