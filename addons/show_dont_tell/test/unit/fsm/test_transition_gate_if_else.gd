extends GdUnitTestSuite
## Tests a TransitionCondition behaves like an if/else block: while the gate
## condition is false, neither the child branch nor its exit is evaluated, so
## no transition happens. Once the gate passes, the first passing branch
## resolves, with the sibling exit as the fallback.

var _first_state: FiniteState
var _second_state: FiniteState

var _gate: TransitionCondition
var _gate_condition: MockCondition

var _branch: TransitionCondition
var _branch_condition: MockCondition
var _branch_exit: TransitionExit
var _fallback_exit: TransitionExit


func before_test() -> void:
	_first_state = auto_free(FiniteState.new())
	_first_state.name = "First"
	_second_state = auto_free(FiniteState.new())
	_second_state.name = "Second"
	_build_test_condition_branch()


## The fallback exit sits directly on the gate, next to the branch. The branch
## holds its own exit, mirroring an if/else with a nested check.
func _build_test_condition_branch() -> void:
	_gate_condition = _make_condition(false)
	_gate = auto_free(TransitionCondition.new())
	_gate.condition = _gate_condition

	_branch_condition = _make_condition(true)
	_branch = auto_free(TransitionCondition.new())
	_branch.condition = _branch_condition
	_branch_exit = auto_free(TransitionExit.new())
	_branch_exit.exit_node = _first_state
	_branch.add_child(_branch_exit)

	_fallback_exit = auto_free(TransitionExit.new())
	_fallback_exit.exit_node = _second_state

	_gate.add_child(_branch)
	_gate.add_child(_fallback_exit)


## The gate is false, so the transition stays closed even when the branch on
## its own would pass.
func test_gate_false_blocks_branch() -> void:
	_gate_condition.should_pass = false
	_branch_condition.should_pass = true

	assert_bool(_gate.can_transition()).is_false()


## While the gate is closed the branch must not be evaluated; its condition
## is never ticked.
func test_gate_false_skips_branch() -> void:
	_gate_condition.should_pass = false

	_gate.can_transition()

	assert_int(_branch_condition.tick_count).is_equal(0)


## Once the gate passes, the first passing branch picks its exit, and the
## sibling exit is the fallback, just like an if/else block.
func test_gate_passes_resolves_branches() -> void:
	_gate_condition.should_pass = true
	assert_bool(_gate.can_transition()).is_true()

	_branch_condition.should_pass = true
	assert_object(_gate.get_exit_node()).is_same(_first_state)

	_branch_condition.should_pass = false
	assert_object(_gate.get_exit_node()).is_same(_second_state)


func _make_condition(passes: bool) -> MockCondition:
	var condition := MockCondition.new()
	condition.should_pass = passes
	return condition


class MockCondition:
	extends TransitionOnCondition

	var should_pass: bool = false
	var tick_count: int = 0

	func _can_transition() -> bool:
		tick_count += 1
		return should_pass
