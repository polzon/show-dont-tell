class_name BehaviorTree
extends BehaviorControl
## BehaviorTree behavior controller.

# TODO:
# Look into expanding upon a simple "Failed" state. For example
# how machine learning treats failure as a function?

enum Status {
	SUCCESS,
	FAILED,
	RUNNING
}

func handle_action(_action: Action) -> void:
	pass
