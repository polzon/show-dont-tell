extends GOAPAgent
## Test script for GOAPAgent flee behavior.
##
## Attach this to an Actor to make it flee from nearby actors.
## Updates world state based on proximity to other actors.

## How often to check for nearby threats (seconds).
@export var threat_check_interval: float = 0.5

## Distance at which to consider an actor a threat (pixels).
@export var threat_detection_range: float = 16.0 * 8.0  # 8 tiles

## Safe distance to maintain from threats (pixels).
@export var safe_distance: float = 16.0 * 5.0  # 5 tiles

var threat_check_timer: float = 0.0
var should_flee: bool = false
var nearest_threat: Actor = null


func _ready() -> void:
	super()

	# Wait for actor to be found.
	await get_tree().process_frame

	if not actor:
		push_error("GOAPAgentFlee: No actor found.")
		return

	# Disable continuous planning - we'll handle movement directly.
	continuous_planning = false

	print("GOAPAgentFlee: Configured for actor %s" % actor.name)


func _physics_process(_delta: float) -> void:
	if not actor or not action_queue:
		return

	# Send continuous flee movement if we should flee.
	if should_flee and nearest_threat:
		var flee_dir: Vector2 = (
			(actor.global_position - nearest_threat.global_position)
			. normalized()
		)

		var move_action := ActionMove.new(actor)
		move_action.input_dir = flee_dir
		action_queue.act(move_action)


func _process(delta: float) -> void:
	super(delta)

	# Update threat detection.
	threat_check_timer += delta
	if threat_check_timer >= threat_check_interval:
		threat_check_timer = 0.0
		_update_threat_detection()


## Updates threat detection - finds nearest actor and decides if we should flee.
func _update_threat_detection() -> void:
	if not actor or not actor.is_inside_tree():
		return

	var tree: SceneTree = actor.get_tree()
	if not tree:
		return

	var actors_group: Array[Node] = tree.get_nodes_in_group("Actors")
	nearest_threat = null
	var nearest_dist: float = INF

	for node: Node in actors_group:
		var other: Variant = node
		if not other is Actor or other == actor:
			continue

		if other is Actor:
			var typed_actor: Actor = other
			var dist: float = actor.global_position.distance_to(
				typed_actor.global_position
			)

			# Find nearest actor within detection range.
			if dist < threat_detection_range and dist < nearest_dist:
				nearest_dist = dist
				nearest_threat = typed_actor

	# Should flee if threat is too close.
	should_flee = nearest_threat != null and nearest_dist < safe_distance
