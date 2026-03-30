class_name GOAPActionFlee
extends GOAPAction
## GOAP action that flees from threats by moving away.

## The actor performing this action.
var flee_actor: Actor

## Minimum safe distance in pixels.
var safe_distance: float = 16.0 * 5.0  # 5 tiles at 16px per tile


func _init(
	actor: Actor, p_safe_distance: float = 16.0 * 5.0, action_cost: float = 1.0
) -> void:
	flee_actor = actor
	safe_distance = p_safe_distance

	super(GOAPWorldState.new(), GOAPWorldState.new(), action_cost)

	# Precondition: There must be a threat nearby.
	preconditions.set_value(&"has_nearby_threat", true)

	# Effect: We will be at safe distance.
	effects.set_value(&"at_safe_distance", true)


## Creates an ActionMove that moves away from the nearest threat.
func create_action() -> Action:
	if not flee_actor:
		push_error("GOAPActionFlee: No actor set.")
		return null

	# Find nearest actor (excluding self).
	var nearest: Actor = _find_nearest_actor()
	if not nearest:
		return null

	# Calculate flee direction (away from nearest actor).
	var flee_dir: Vector2 = (
		(flee_actor.global_position - nearest.global_position).normalized()
	)

	# Create ActionMove with flee direction.
	var move_action := ActionMove.new(flee_actor)
	move_action.input_dir = flee_dir

	return move_action


## Returns the action name for debugging.
func get_action_name() -> String:
	return "Flee"


## Finds the nearest actor (excluding self).
func _find_nearest_actor() -> Actor:
	if not flee_actor or not flee_actor.is_inside_tree():
		return null

	var tree: SceneTree = flee_actor.get_tree()
	if not tree:
		return null

	var actors: Array[Node] = tree.get_nodes_in_group("Actors")
	var nearest: Actor = null
	var nearest_dist: float = INF

	for node: Node in actors:
		var actor: Variant = node
		if not actor is Actor or actor == flee_actor:
			continue

		if actor is Actor:
			var typed_actor: Actor = actor
			var dist: float = flee_actor.global_position.distance_to(
				typed_actor.global_position
			)

			# Only consider actors within detection range.
			if dist < safe_distance * 2.0 and dist < nearest_dist:
				nearest_dist = dist
				nearest = typed_actor

	return nearest
