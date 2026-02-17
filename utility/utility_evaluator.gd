class_name UtilityEvaluator
extends RefCounted
## Evaluates multiple utility actions and selects the best one.
##
## The evaluator scores all available actions for the given actor/context
## and returns the highest-scoring action. Useful for AI decision-making.

## Available actions to evaluate.
var actions: Array[UtilityAction] = []


## Adds an action to the evaluator.
func add_action(action: UtilityAction) -> void:
	actions.append(action)


## Removes an action from the evaluator.
func remove_action(action: UtilityAction) -> void:
	actions.erase(action)


## Clears all actions.
func clear_actions() -> void:
	actions.clear()


## Evaluates all actions and returns the highest-scoring one.
## Returns null if no actions are available or all score 0.
func evaluate_best(actor: Actor, context: Dictionary = {}) -> UtilityAction:
	if actions.is_empty():
		return null

	var best_action: UtilityAction = null
	var best_score: float = - INF

	for action: UtilityAction in actions:
		if not action:
			continue

		var score: float = action.evaluate(actor, context)

		if score > best_score:
			best_score = score
			best_action = action

	# Only return if score is above 0.
	if best_score <= 0.0:
		return null

	return best_action


## Evaluates all actions and returns them sorted by score (highest first).
## Useful for debugging or fallback logic.
func evaluate_all(actor: Actor, context: Dictionary = {}) -> Array[Dictionary]:
	var scored_actions: Array[Dictionary] = []

	for action: UtilityAction in actions:
		if not action:
			continue

		var score: float = action.evaluate(actor, context)
		scored_actions.append({"action": action, "score": score})

	# Sort by score descending.
	scored_actions.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return a["score"] > b["score"]
	)

	return scored_actions
