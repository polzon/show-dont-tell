@icon("uid://c5gw354thiofm")
class_name TransitionMethod
extends Node

## List of conditions where none must fail in order for a transition to be
## valid. If the condition array is empty, it will be assumed that we
## can transition.
@export var conditions: Array[TransitionOnCondition] = []

## The exit node to transition to if all conditions are met.
@export var exit_node: FiniteState


func can_transition() -> bool:
	for condition in conditions:
		if not condition.can_transition():
			return false
	return true
