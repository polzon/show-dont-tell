class_name IntentSolver
extends RefCounted

var state_machine: StateMachine

var _plan: Array[PlanStep] = []
var _target: FiniteState


func get_available_intents() -> Array[FiniteState]:
	var start := state_machine.state
	if not start:
		return []
	var queue: Array[FiniteState] = [start]
	var visited := {start: true}
	var intents: Array[FiniteState] = []
	while not queue.is_empty():
		var current: FiniteState = queue.pop_front()
		for transition: TransitionCondition in _transitions_from(current):
			if not transition.can_transition():
				continue
			var exit_node := transition.get_exit_node()
			if not exit_node or visited.has(exit_node):
				continue
			visited[exit_node] = true
			intents.append(exit_node)
			queue.append(exit_node)
	return intents


func _transitions_from(state: FiniteState) -> Array[TransitionCondition]:
	var transitions: Array[TransitionCondition] = []
	for child: Node in state.get_children():
		var transition := child as TransitionCondition
		if transition:
			transitions.append(transition)
	return transitions


func navigate_to(target: FiniteState) -> bool:
	if not state_machine:
		return false
	if state_machine.state == target:
		_plan.clear()
		_target = null
		return true
	var steps := _solve(target)
	if steps.is_empty():
		return false
	_plan = steps
	_target = target
	return true


func _solve(target: FiniteState) -> Array[PlanStep]:
	var start := state_machine.state
	if not start:
		return []
	var queue: Array[FiniteState] = [start]
	var visited := {start: true}
	var came_from := {}
	while not queue.is_empty():
		var current: FiniteState = queue.pop_front()
		for transition: TransitionCondition in _transitions_from(current):
			if not transition.can_transition():
				continue
			var exit_node := transition.get_exit_node()
			if not exit_node or visited.has(exit_node):
				continue
			visited[exit_node] = true
			came_from[exit_node] = {
				"transition": transition,
				"previous": current,
			}
			if exit_node == target:
				return _reconstruct(came_from, target)
			queue.append(exit_node)
	return []


func _reconstruct(
	came_from: Dictionary, target: FiniteState
) -> Array[PlanStep]:
	var steps: Array[PlanStep] = []
	var current: FiniteState = target
	while came_from.has(current):
		var entry: Dictionary = came_from[current]
		var transition: TransitionCondition = entry["transition"]
		steps.push_front(PlanStep.new(transition, current))
		current = entry["previous"]
	return steps


func advance() -> bool:
	if not state_machine or not state_machine.enabled:
		return false
	if _plan.is_empty():
		return false
	var step: PlanStep = _plan[0]
	if not step.transition.can_transition():
		if not _replan():
			return false
		step = _plan[0]
		if not step.transition.can_transition():
			_plan.clear()
			return false
	step.transition.before_transition()
	state_machine.change_state_node(step.target_state)
	step.transition.after_transition()
	_plan.pop_front()
	return true


func has_active_plan() -> bool:
	return not _plan.is_empty()


func _replan() -> bool:
	if not _target:
		_plan.clear()
		return false
	var steps := _solve(_target)
	if steps.is_empty():
		_plan.clear()
		return false
	_plan = steps
	return true


class PlanStep:
	var transition: TransitionCondition
	var target_state: FiniteState

	func _init(
		p_transition: TransitionCondition, p_target: FiniteState
	) -> void:
		transition = p_transition
		target_state = p_target
