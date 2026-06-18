@abstract class_name TransitionRule
extends Resource

## The node that the transition will exit to.
@export_node_path("FiniteState") var exit_path: NodePath


func handle_command(_command: Command) -> void:
	pass


## Checks if a transition can be performed.
@abstract func can_transition() -> bool


func _on_transition(_state: FiniteState) -> void:
	return
