class_name GOAPPlanner
extends RefCounted
## A* planner for GOAP command sequences.
##
## Plans optimal command sequences by searching backward from a goal state
## to the current world state. Uses A* pathfinding with command costs and
## heuristics to find efficient plans.


## Internal node class for A* search.
class PlanNode:
	extends RefCounted
	## World state at this node.
	var state: GOAPWorldState

	## Command that led to this node (null for goal node).
	var command: GOAPCommand

	## Parent node in search tree.
	var parent: PlanNode

	## Cost from goal to this node.
	var g_cost: float

	## Heuristic cost from this node to start.
	var h_cost: float

	## Total cost (g_cost + h_cost).
	var f_cost: float:
		get:
			return g_cost + h_cost

	func _init(
		p_state: GOAPWorldState,
		p_command: GOAPCommand = null,
		p_parent: PlanNode = null,
		p_g_cost: float = 0.0,
		p_h_cost: float = 0.0
	) -> void:
		state = p_state
		command = p_command
		parent = p_parent
		g_cost = p_g_cost
		h_cost = p_h_cost


## Maximum planning iterations before giving up.
## Prevents infinite loops in complex planning scenarios.
@export var max_iterations: int = 1000


## Plans an command sequence from current state to goal.
## Returns array of GOAPCommands in execution order, or empty array if no plan.
func plan(
	current_state: GOAPWorldState,
	goal: GOAPGoal,
	available_commands: Array[GOAPCommand]
) -> Array[GOAPCommand]:
	# Check if goal already satisfied.
	if goal.is_satisfied(current_state):
		return []

	var open_list: Array[PlanNode] = []
	var closed_list: Array[GOAPWorldState] = []

	# Start with goal state.
	var start_node: PlanNode = PlanNode.new(
		goal.target_state.duplicate(), null, null, 0.0, 0.0
	)
	open_list.append(start_node)

	var iterations: int = 0

	while open_list.size() > 0 and iterations < max_iterations:
		iterations += 1

		# Get node with lowest F-cost.
		var current: PlanNode = _get_lowest_f_cost_node(open_list)
		open_list.erase(current)

		# Check if we've reached the current state.
		if current_state.satisfies(current.state):
			return _reconstruct_plan(current)

		closed_list.append(current.state)

		# Expand neighbors (commands that could lead here).
		for command: GOAPCommand in available_commands:
			# Skip if preconditions not met.
			if not current_state.satisfies(command.preconditions):
				continue

			# Check if command's effects contribute to current node's state.
			if not _command_contributes(command, current.state):
				continue

			# Create new state by removing command's effects.
			var new_state: GOAPWorldState = _apply_command_backward(
				current.state, command
			)

			# Skip if already closed.
			if _is_state_in_list(new_state, closed_list):
				continue

			# Calculate costs.
			var g_cost: float = current.g_cost + command.cost
			var h_cost: float = _calculate_heuristic(new_state, current_state)

			# Check if this is a better path to an existing node.
			var existing: PlanNode = _find_node_with_state(new_state, open_list)
			if existing:
				if g_cost < existing.g_cost:
					existing.parent = current
					existing.command = command
					existing.g_cost = g_cost
					existing.h_cost = h_cost
				continue

			# Add new node.
			var new_node: PlanNode = PlanNode.new(
				new_state, command, current, g_cost, h_cost
			)
			open_list.append(new_node)

	# No plan found.
	return []


## Returns the node with the lowest F-cost from the list.
func _get_lowest_f_cost_node(nodes: Array[PlanNode]) -> PlanNode:
	var lowest: PlanNode = nodes[0]
	for node: PlanNode in nodes:
		if node.f_cost < lowest.f_cost:
			lowest = node
	return lowest


## Reconstructs the command sequence from a goal node.
## Returns commands in execution order (start to goal).
func _reconstruct_plan(goal_node: PlanNode) -> Array[GOAPCommand]:
	var commands: Array[GOAPCommand] = []
	var current: PlanNode = goal_node

	while current.parent != null:
		commands.push_front(current.command)
		current = current.parent

	return commands


## Returns true if the command's effects contribute to the target state.
func _command_contributes(
	command: GOAPCommand, target_state: GOAPWorldState
) -> bool:
	var effect_keys: Array[StringName] = command.effects.get_keys()
	var target_keys: Array[StringName] = target_state.get_keys()

	for key: StringName in effect_keys:
		if key in target_keys:
			var effect_value: Variant = command.effects.get_value(key)
			var target_value: Variant = target_state.get_value(key)
			if effect_value == target_value:
				return true

	return false


## Applies an command backward (removes its effects from state).
func _apply_command_backward(
	state: GOAPWorldState, command: GOAPCommand
) -> GOAPWorldState:
	var new_state: GOAPWorldState = state.duplicate()

	# Remove satisfied conditions that this command provides.
	for key: StringName in command.effects.get_keys():
		if new_state.has(key):
			var effect_value: Variant = command.effects.get_value(key)
			var state_value: Variant = new_state.get_value(key)
			if effect_value == state_value:
				new_state.erase(key)

	# Add command's preconditions as new requirements.
	new_state.apply_effects(command.preconditions)

	return new_state


## Calculates heuristic cost from state to current state.
## Uses number of unsatisfied conditions.
func _calculate_heuristic(
	state: GOAPWorldState, target: GOAPWorldState
) -> float:
	var unsatisfied: int = 0

	for key: StringName in state.get_keys():
		if not target.has(key) or target.get_value(key) != state.get_value(key):
			unsatisfied += 1

	return float(unsatisfied)


## Returns true if state matches any in the list.
func _is_state_in_list(
	state: GOAPWorldState, states: Array[GOAPWorldState]
) -> bool:
	for other: GOAPWorldState in states:
		if _states_equal(state, other):
			return true
	return false


## Finds a node with matching state in the list.
func _find_node_with_state(
	state: GOAPWorldState, nodes: Array[PlanNode]
) -> PlanNode:
	for node: PlanNode in nodes:
		if _states_equal(state, node.state):
			return node
	return null


## Returns true if two states are equal.
func _states_equal(a: GOAPWorldState, b: GOAPWorldState) -> bool:
	var a_keys: Array[StringName] = a.get_keys()
	var b_keys: Array[StringName] = b.get_keys()

	if a_keys.size() != b_keys.size():
		return false

	for key: StringName in a_keys:
		if not b.has(key) or a.get_value(key) != b.get_value(key):
			return false

	return true
