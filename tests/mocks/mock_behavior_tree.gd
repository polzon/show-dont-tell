class_name MockBehaviorTree
extends BehaviorTree
## Mock [BehaviorTree] for testing components without full initialization.

# ! Can be removed and replaced with mock() in unit tests.


func _tick(_delta: float) -> Status:
	return Status.SUCCESS
