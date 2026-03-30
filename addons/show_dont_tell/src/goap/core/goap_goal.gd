class_name GOAPGoal
extends RefCounted
## Represents a goal for GOAP planning.
##
## A goal defines a desired world state and a priority value for goal
## selection. The planner uses goals to determine what actions to take.

## The desired world state this goal wants to achieve.
var target_state: GOAPWorldState

## Priority for goal selection. Higher values = higher priority.
## Used when an agent has multiple active goals.
var priority: float


func _init(
	p_target_state: GOAPWorldState = null, p_priority: float = 1.0
) -> void:
	target_state = (p_target_state if p_target_state else GOAPWorldState.new())
	priority = p_priority


## Returns true if the given world state satisfies this goal.
func is_satisfied(state: GOAPWorldState) -> bool:
	return state.satisfies(target_state)


## Sets a target state value for this goal.
func set_target(key: StringName, value: Variant) -> void:
	target_state.set_value(key, value)


## Gets a target state value from this goal.
func get_target(key: StringName, default_value: Variant = null) -> Variant:
	return target_state.get_value(key, default_value)


## Clears all target state requirements.
func clear_targets() -> void:
	target_state.clear()


## Returns a duplicate of this goal.
func duplicate() -> GOAPGoal:
	var goal: GOAPGoal = GOAPGoal.new()
	goal.target_state = target_state.duplicate()
	goal.priority = priority
	return goal


## Returns the target state as a string for debugging.
func _to_string() -> String:
	return (
		"GOAPGoal(priority=%s, target=%s)"
		% [
			priority,
			target_state.to_dict(),
		]
	)
