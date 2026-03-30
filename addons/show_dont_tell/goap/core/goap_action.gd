@abstract class_name GOAPAction
extends RefCounted
## Base class for GOAP action metadata.
##
## GOAPActions describe planning-level requirements (preconditions, effects,
## cost) and create/configure actual Action instances for execution.
## This separates planning from execution, allowing the GOAP planner to
## reason about actions without creating expensive runtime objects.

## Preconditions required for this action to be valid.
## The world state must satisfy these for the planner to consider this action.
var preconditions: GOAPWorldState

## Effects this action has on the world state.
## Applied to predict state changes during planning.
var effects: GOAPWorldState

## Planning cost for A* search. Lower cost = preferred action.
## Default 1.0. Increase for "expensive" actions, decrease for preferred ones.
var cost: float


func _init(
	p_preconditions: GOAPWorldState = null,
	p_effects: GOAPWorldState = null,
	p_cost: float = 1.0
) -> void:
	preconditions = (
		p_preconditions if p_preconditions else GOAPWorldState.new()
	)
	effects = p_effects if p_effects else GOAPWorldState.new()
	cost = p_cost


## Returns true if this action's preconditions are satisfied by the state.
func can_run(state: GOAPWorldState) -> bool:
	return state.satisfies(preconditions)


## Applies this action's effects to a world state (for planning).
## Returns a new state with effects applied.
func apply_to_state(state: GOAPWorldState) -> GOAPWorldState:
	var new_state: GOAPWorldState = state.duplicate()
	new_state.apply_effects(effects)
	return new_state


## Creates and configures an Action instance for execution.
## Override in subclasses to return specific Action types.
## Called by GOAPAgent when executing a planned action sequence.
@abstract func create_action() -> Action


## Sets a precondition key-value requirement.
func set_precondition(key: StringName, value: Variant) -> void:
	preconditions.set_value(key, value)


## Sets an effect key-value change.
func set_effect(key: StringName, value: Variant) -> void:
	effects.set_value(key, value)


## Returns this action's name for debugging.
## Override in subclasses to provide meaningful names.
func get_action_name() -> String:
	return "GOAPAction"


## Returns a string representation for debugging.
func _to_string() -> String:
	return (
		"GOAPAction(%s, cost=%s, pre=%s, eff=%s)"
		% [
			get_action_name(),
			cost,
			preconditions.to_dict(),
			effects.to_dict(),
		]
	)
