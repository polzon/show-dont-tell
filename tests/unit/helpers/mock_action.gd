class_name MockAction
extends ActorAction
## Mock Action for testing action handling in FSM/BTree.
##
## Allows tests to track whether the action was created, performed, or
## handled by state machines/behavior trees.

var was_performed: bool = false
var perform_count: int = 0


func _init(new_actor: Actor = null) -> void:
	super._init(new_actor)


func _execute() -> void:
	was_performed = true
	perform_count += 1
