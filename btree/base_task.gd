@abstract
class_name BT_BaseTask
extends Node
## The core of a [BehaviorTree] task that everything is extended from.

const Status = BehaviorTree.Status

## Base process tick function that is triggered every [BehaviorTree]
## process updates. This function updates every possible frame.
func _process_tick() -> Status:
	return Status.FAILED


## Base physics tick function that is triggered every [BehaviorTree]
## physics update. This function updates every physics update.
func _physics_tick() -> Status:
	return Status.FAILED
