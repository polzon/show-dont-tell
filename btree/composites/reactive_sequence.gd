@icon("res://addons/show_not_tell/icons/sequence_reactive.svg")
class_name BT_ReactiveSequence
extends BT_SequenceComposite


func _tick(_delta: float) -> Status:
	return Status.FAILED
