@icon("res://addons/show_not_tell/icons/sequence_random.svg")
class_name BT_RandomSequence
extends BT_SequenceComposite


func _tick(_delta: float) -> Status:
	return Status.FAILED
