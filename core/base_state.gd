class_name BaseState
extends Node
## The origin node that all behavior derrives from.


## Function that is internally called whenever a [BaseState] is updated.
func _tick() -> void:
	pass


## Processed when the [BaseState] has started.
func _state_started() -> void:
	pass


## Processed when the [BaseState] has ended.
func _state_ended() -> void:
	pass
