class_name UtilityConsideration
extends Resource
## Base class for a single factor in utility calculations.
##
## A consideration evaluates one aspect of the game state (e.g., health,
## distance, ammo) and returns a 0-1 score using a response curve.
## Multiple considerations combine to determine action utility.

## The response curve to map raw values to scores.
@export var curve: UtilityCurve

## Minimum value for normalization.
@export var min_value: float = 0.0

## Maximum value for normalization.
@export var max_value: float = 1.0


func _init(
	p_curve: UtilityCurve = null, p_min: float = 0.0, p_max: float = 1.0
) -> void:
	curve = p_curve if p_curve else UtilityCurve.linear()
	min_value = p_min
	max_value = p_max


## Evaluates this consideration given an actor and optional context.
## Override in subclasses to implement specific logic.
## Should return a raw value that will be normalized and passed to the curve.
func evaluate(actor: Actor, context: Dictionary = {}) -> float:
	var raw_value: float = get_raw_value(actor, context)
	var normalized: float = normalize_value(raw_value)
	return curve.evaluate(normalized)


## Gets the raw value for this consideration.
## Override this in subclasses.
func get_raw_value(_actor: Actor, _context: Dictionary) -> float:
	push_warning(
		(
			"UtilityConsideration.get_raw_value() not overridden in %s"
			% get_script().resource_path
		)
	)
	return 0.0


## Normalizes a raw value to 0-1 range.
func normalize_value(raw_value: float) -> float:
	# When min and max are the same, treat the single valid point as fully
	# satisfied and return a normalized score of 1.0.
	if is_equal_approx(max_value, min_value):
		return 1.0

	if max_value < min_value:
		return 0.0

	return clampf(
		(raw_value - min_value) / (max_value - min_value), 0.0, 1.0
	)
