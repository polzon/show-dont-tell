class_name MockCommand
extends ActorCommand
## Mock [ActorCommand] for testing command handling in FSM/BTree.
##
## Allows tests to track whether the command was created, performed, or
## handled by [StateMachine]/[BehaviorTree]s.

var was_performed: bool = false
var perform_count: int = 0


func _init(new_actor: Actor = null) -> void:
	super._init(new_actor)


func _execute() -> void:
	was_performed = true
	perform_count += 1
