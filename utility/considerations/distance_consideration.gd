class_name DistanceConsideration
extends UtilityConsideration
## Consideration that scores based on distance to a target.

## Key in context dictionary for target position (Vector2).
@export var target_key: StringName = &"target_position"


func _init(
	p_curve: UtilityCurve = null,
	p_min_dist: float = 0.0,
	p_max_dist: float = 500.0
) -> void:
	super (p_curve, p_min_dist, p_max_dist)


func get_raw_value(actor: Actor, context: Dictionary) -> float:
	if not context.has(target_key):
		return max_value # Assume far away if no target

	var target_pos: Variant = context.get(target_key)
	if not target_pos is Vector2:
		return max_value

	var target_position: Vector2 = target_pos
	return actor.global_position.distance_to(target_position)
