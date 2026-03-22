class_name UtilityAction
extends Resource
## An action with utility scoring based on multiple considerations.
##
## Evaluates all considerations and combines them to produce a final
## utility score. The evaluator picks the highest-scoring action.

## The considerations that determine this action's utility.
@export var considerations: Array[UtilityConsideration] = []

## Base score multiplier. Can be used to boost/reduce action priority.
@export var base_multiplier: float = 1.0

## Bonus score added after combining considerations.
@export var bonus: float = 0.0


## Evaluates the utility of this action for the given actor and context.
## Returns a score from 0-1 (or slightly higher with bonuses).
func evaluate(actor: Actor, context: Dictionary = {}) -> float:
	if considerations.is_empty():
		return base_multiplier + bonus

	var combined_score: float = 1.0

	# Multiply all consideration scores together.
	for consideration: UtilityConsideration in considerations:
		if not consideration:
			continue
		var score: float = consideration.evaluate(actor, context)
		combined_score *= score

	# Apply base multiplier and bonus.
	combined_score = (combined_score * base_multiplier) + bonus

	return clampf(combined_score, 0.0, 1.0)


## Adds a consideration to this action.
func add_consideration(consideration: UtilityConsideration) -> void:
	considerations.append(consideration)


## Executes this action's behavior.
## Override in subclasses or use composition with GOAPAction.
func execute(_actor: Actor, _context: Dictionary = {}) -> void:
	push_warning(
		(
			"UtilityAction.execute() not implemented in %s"
			% get_script().resource_path
		)
	)
