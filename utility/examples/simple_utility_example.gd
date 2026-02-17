extends GOAPAgent
## Simple utility AI example using only distance.
##
## Demonstrates utility-based goal selection without requiring health.
## - When enemy is close (< 5 tiles): FLEE goal (high priority)
## - When enemy is far (> 5 tiles): IDLE goal (high priority)

## Fallback distance for when no threat exists.
const FALLBACK_FAR_DISTANCE: float = 999999.0

## Distance thresholds.
@export var threat_detection_range: float = 16.0 * 10.0 # 10 tiles
@export var safe_distance: float = 16.0 * 5.0 # 5 tiles

var threat_check_timer: float = 0.0
var flee_goal: UtilityGOAPGoal
var idle_goal: UtilityGOAPGoal
var nearest_threat: Actor = null


func _ready() -> void:
	super ()

	await get_tree().process_frame

	if not actor:
		push_error("SimpleUtilityExample: No actor found.")
		return

	_setup_goals()

	print("SimpleUtilityExample: Configured for actor %s" % actor.name)


func _setup_goals() -> void:
	# FLEE GOAL: High utility when enemy is close.
	flee_goal = UtilityGOAPGoal.new(GOAPWorldState.new(), 10.0)
	flee_goal.set_target(&"fleeing", true)

	# Distance consideration: high score when close to threat.
	# Invert the curve so close = 1.0, far = 0.0.
	# Only care about threats within safe distance.
	var flee_distance := DistanceConsideration.new(
		UtilityCurve.linear(1.0, true), 0.0, safe_distance
	)
	flee_goal.add_consideration(flee_distance)

	add_goal(flee_goal)

	# IDLE GOAL: High utility when enemy is far.
	idle_goal = UtilityGOAPGoal.new(GOAPWorldState.new(), 10.0)
	idle_goal.set_target(&"idle", true)

	# Distance consideration: high score when far from threat.
	# Normal curve so far = 1.0, close = 0.0.
	var idle_distance := DistanceConsideration.new(
		UtilityCurve.linear(1.0, false), 0.0, safe_distance
	)
	idle_goal.add_consideration(idle_distance)

	add_goal(idle_goal)


func _physics_process(_delta: float) -> void:
	if not actor or not action_queue:
		return

	if not flee_goal or not idle_goal:
		return

	# If fleeing is the active goal, send movement.
	if flee_goal.priority > idle_goal.priority and nearest_threat:
		var flee_dir: Vector2 = (
			(actor.global_position - nearest_threat.global_position)
			.normalized()
		)

		var move_action := ActionMove.new(actor)
		move_action.input_dir = flee_dir
		action_queue.act(move_action)


func _process(delta: float) -> void:
	super (delta)

	# Update goal priorities using utility AI.
	threat_check_timer += delta
	if threat_check_timer >= 0.2: # 5 times per second
		threat_check_timer = 0.0
		_update_goal_priorities()


func _update_goal_priorities() -> void:
	if not actor or not actor.is_inside_tree():
		return

	# Find nearest threat.
	nearest_threat = _find_nearest_threat()

	var context := {}
	if nearest_threat:
		context[&"target_position"] = nearest_threat.global_position
	else:
		# No threat - set far away position to ensure idle scores high.
		context[&"target_position"] = (
			actor.global_position
			+ Vector2(FALLBACK_FAR_DISTANCE, FALLBACK_FAR_DISTANCE)
		)

	# Evaluate utility goals - they update their own priority.
	flee_goal.evaluate_priority(actor, context)
	idle_goal.evaluate_priority(actor, context)

	# Debug output.
	if OS.is_debug_build():
		var flee_score: float = flee_goal.priority
		var idle_score: float = idle_goal.priority
		var dist: float = INF

		if nearest_threat:
			var target_pos: Variant = context.get(&"target_position")
			if target_pos is Vector2:
				var target_position: Vector2 = target_pos
				dist = actor.global_position.distance_to(target_position)

		if threat_check_timer == 0.0: # Only print on update
			print(
				(
					"[%s] Dist: %.1f | Flee: %.2f | Idle: %.2f | Winner: %s"
					% [
						actor.name,
						dist,
						flee_score,
						idle_score,
						"FLEE" if flee_score > idle_score else "IDLE",
					]
				)
			)


func _find_nearest_threat() -> Actor:
	if not actor.is_inside_tree():
		return null

	var tree: SceneTree = actor.get_tree()
	if not tree:
		return null

	var actors_group: Array[Node] = tree.get_nodes_in_group("Actors")
	var nearest: Actor = null
	var nearest_dist: float = INF

	for node: Node in actors_group:
		var other: Variant = node
		if not other is Actor or other == actor:
			continue

		var typed_actor: Actor = other
		var dist: float = actor.global_position.distance_to(
			typed_actor.global_position
		)

		if dist < threat_detection_range and dist < nearest_dist:
			nearest_dist = dist
			nearest = typed_actor

	return nearest
