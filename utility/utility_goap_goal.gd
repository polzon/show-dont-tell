class_name UtilityGOAPGoal
extends GOAPGoal
## A GOAP goal with utility considerations for dynamic prioritization.
##
## Instead of fixed priority, this goal's priority is calculated each frame
## using utility AI considerations. This allows goals to change priority
## based on the current game state.

## Considerations used to calculate this goal's utility score.
var considerations: Array[UtilityConsideration] = []

## Base priority multiplier.
var base_priority: float = 1.0


func _init(
	p_target_state: GOAPWorldState = null, p_base_priority: float = 1.0
) -> void:
	super (p_target_state, p_base_priority)
	base_priority = p_base_priority


## Adds a consideration to this goal.
func add_consideration(consideration: UtilityConsideration) -> void:
	considerations.append(consideration)


## Evaluates this goal's priority using utility considerations.
## Call this each frame to update priority based on current state.
func evaluate_priority(actor: Actor, context: Dictionary = {}) -> float:
	if considerations.is_empty():
		return base_priority

	var combined_score: float = 1.0

	# Multiply all consideration scores together.
	for consideration: UtilityConsideration in considerations:
		if not consideration:
			continue
		var score: float = consideration.evaluate(actor, context)
		combined_score *= score

	# Apply base priority multiplier.
	priority = combined_score * base_priority
	return priority
