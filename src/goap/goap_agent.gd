class_name GOAPAgent
extends Node
## GOAP agent controller that plans and executes action sequences.
##
## The GOAPAgent is a controller that uses GOAP planning to achieve goals.
## It maintains a world state, plans action sequences using GOAPPlanner,
## and queues actions to an ActionQueue for execution.
## This integrates with the existing Actor/ActionQueue architecture.

## Whether the agent should continuously replan.
@export var continuous_planning: bool = true

## How often to replan (in seconds). Only used if continuous_planning is true.
@export var replan_interval: float = 1.0

## Current world state the agent uses for planning.
var world_state: GOAPWorldState

## Available GOAP actions the agent can use.
var available_actions: Array[GOAPAction] = []

## Active goals the agent is trying to achieve.
var goals: Array[GOAPGoal] = []

## The planner used to generate action sequences.
var planner: GOAPPlanner

## The actor this agent controls.
var actor: Actor

## Action queue to send planned actions to.
var action_queue: ActionQueue:
	get:
		if actor:
			return actor.action_queue
		return null

## Current plan being executed.
var current_plan: Array[GOAPAction] = []

## Index of current action in the plan.
var current_action_index: int = 0

## Timer for replanning.
var replan_timer: float = 0.0


func _init() -> void:
	world_state = GOAPWorldState.new()
	planner = GOAPPlanner.new()


func _ready() -> void:
	_find_actor()


## Finds the Actor this agent controls.
func _find_actor() -> void:
	# Check if parent is an Actor.
	var parent: Node = get_parent()
	if parent is Actor:
		actor = parent
		return

	# Search for Actor in parent's tree.
	if parent:
		var results: Array[Node] = parent.find_children(
			"*", "Actor", true, false
		)

		if results.size() > 0:
			var found: Variant = results[0]
			if found is Actor:
				actor = found

	if not actor:
		push_warning(
			"GOAPAgent: Could not find Actor. Agent will not execute plans."
		)


func _process(delta: float) -> void:
	if not continuous_planning:
		return

	replan_timer += delta
	if replan_timer >= replan_interval:
		replan_timer = 0.0
		_try_replan()


## Attempts to create a new plan if needed.
func _try_replan() -> void:
	# Skip if we have a valid plan in progress.
	if current_plan.size() > 0 and current_action_index < current_plan.size():
		return

	# Find highest priority goal.
	var goal: GOAPGoal = _get_highest_priority_goal()
	if not goal:
		return

	# Check if goal already satisfied.
	if goal.is_satisfied(world_state):
		return

	# Plan new action sequence.
	var plan: Array[GOAPAction] = planner.plan(
		world_state, goal, available_actions
	)

	if plan.size() > 0:
		_execute_plan(plan)


## Returns the highest priority unsatisfied goal.
func _get_highest_priority_goal() -> GOAPGoal:
	var best_goal: GOAPGoal = null
	var best_priority: float = -INF

	for goal: GOAPGoal in goals:
		if goal.is_satisfied(world_state):
			continue
		if goal.priority > best_priority:
			best_priority = goal.priority
			best_goal = goal

	return best_goal


## Executes a planned action sequence.
func _execute_plan(plan: Array[GOAPAction]) -> void:
	current_plan = plan
	current_action_index = 0
	_execute_next_action()


## Executes the next action in the current plan.
func _execute_next_action() -> void:
	if current_action_index >= current_plan.size():
		_on_plan_complete()
		return

	if not action_queue:
		push_warning("GOAPAgent: No ActionQueue to execute plan.")
		return

	var goap_action: GOAPAction = current_plan[current_action_index]
	var action: Action = goap_action.create_action()

	if not action:
		push_error(
			(
				"GOAPAgent: GOAP action %s failed to create Action instance."
				% goap_action.get_action_name()
			)
		)
		_on_plan_failed()
		return

	# Queue the action for execution.
	action_queue.act(action)

	# Apply predicted effects to world state.
	world_state.apply_effects(goap_action.effects)

	current_action_index += 1

	# Execute next action (for now, queue all actions at once).
	# In a more advanced implementation, we'd wait for action completion.
	_execute_next_action()


## Called when plan completes successfully.
func _on_plan_complete() -> void:
	current_plan.clear()
	current_action_index = 0


## Called when plan fails.
func _on_plan_failed() -> void:
	current_plan.clear()
	current_action_index = 0


## Adds a GOAP action to the agent's available actions.
func add_action(action: GOAPAction) -> void:
	available_actions.append(action)


## Removes a GOAP action from available actions.
func remove_action(action: GOAPAction) -> void:
	available_actions.erase(action)


## Adds a goal to the agent.
func add_goal(goal: GOAPGoal) -> void:
	goals.append(goal)


## Removes a goal from the agent.
func remove_goal(goal: GOAPGoal) -> void:
	goals.erase(goal)


## Forces an immediate replan.
func force_replan() -> void:
	current_plan.clear()
	current_action_index = 0
	_try_replan()
