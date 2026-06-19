@abstract
@icon("uid://btrq8e0kyxthg")
class_name StateData
extends Resource

signal state_timeout

var parent_state: FiniteState

## The [StateMachine] that is handling the [FiniteState].
var state_machine: StateMachine


func handle_command(_command: Command) -> void:
	pass


func register_state(state: FiniteState) -> void:
	parent_state = state
	state_machine = parent_state.get_state_machine()


func _process_tick(_delta: float) -> void:
	pass


func _physics_tick(_delta: float) -> void:
	pass


func _on_state_start() -> void:
	pass


func exit_state() -> void:
	state_timeout.emit()
	_on_state_end()


func _on_state_end() -> void:
	pass
