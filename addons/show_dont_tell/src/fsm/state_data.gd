@abstract
@icon("uid://btrq8e0kyxthg")
class_name StateData
extends Resource

var parent_state: FiniteState

## The [StateMachine] that is handling the [FiniteState].
var state_machine: StateMachine


func register_state(state: FiniteState) -> void:
	parent_state = state
	state_machine = parent_state.get_state_machine()


func _process_tick(_delta: float) -> void:
	pass


func _physics_tick(_delta: float) -> void:
	pass


func _on_state_start() -> void:
	pass


func _on_state_end() -> void:
	pass
