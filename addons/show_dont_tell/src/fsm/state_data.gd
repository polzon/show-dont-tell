@abstract
@icon("uid://btrq8e0kyxthg")
class_name StateData
extends Resource

signal state_started
signal state_ended
## When the state naturally calls its exit.
signal state_timeout

var parent_state: FiniteState
## The [StateMachine] that is handling the [FiniteState].
var state_machine: StateMachine


func handle_command(_command: Command) -> void:
	pass


func process_tick(_delta: float) -> void:
	pass


func physics_tick(_delta: float) -> void:
	pass


## Called externally by the [FiniteState] when the state is being entered.
func state_start() -> void:
	state_started.emit()
	_on_state_start()


## Internal function called when the state is being entered.
func _on_state_start() -> void:
	pass


## Called externally by the [FiniteState] when the state is being exited.
func exit_state() -> void:
	_on_state_end()
	state_ended.emit()


## Internal function called when the state is being exited.
## This is called before [signal state_ended] is emitted.
func _on_state_end() -> void:
	pass


## Called by this class when the state requests and exit or wants to leave.
func request_exit() -> void:
	state_timeout.emit()
