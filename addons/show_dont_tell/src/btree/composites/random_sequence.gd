@icon("res://addons/show_not_tell/icons/sequence_random.svg")
class_name BT_RandomSequence
extends BT_SequenceComposite


func _entered_state() -> void:
	_shuffle_and_reset()
	super._entered_state()


func _exited_state() -> void:
	_clear_shuffle()
	super._exited_state()


func _tick(delta: float) -> Status:
	while current_child_index < shuffled_children.size():
		var child: BehaviorTask = shuffled_children[current_child_index]
		var child_status: Status = child.execute(delta)

		if child_status == RUNNING:
			return RUNNING
		if child_status == FAILED:
			return FAILED

		current_child_index += 1

	return SUCCESS
