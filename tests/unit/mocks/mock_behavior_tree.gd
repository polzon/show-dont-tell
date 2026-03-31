class_name MockBehaviorTree
extends BehaviorTree
## Mock BehaviorTree for testing BT components without full initialization.


func _tick(_delta: float) -> Status:
	return Status.SUCCESS
