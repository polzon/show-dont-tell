extends GdUnitTestSuite

## Nested TransitionCondition nodes resolve the exit node by walking child
## conditions in order: a passing parent still checks its children, and a
## failing child falls through to the next sibling.

const EXIT_NONE := 0
const EXIT_FIRST := 1
const EXIT_SECOND := 2

const CAN_TRANSITION_CASES: Array[Array] = [
	# [parent, child1, child2, can_transition]
	[true, true, false, true],
	[true, false, true, true],
	[true, false, false, true],
	[false, true, false, true],
	[false, false, true, true],
	[false, false, false, false],
]

const EXIT_CASES: Array[Array] = [
	# [parent, child1, child2, exit]
	[true, true, false, EXIT_FIRST],
	[true, false, true, EXIT_SECOND],
	[false, true, false, EXIT_FIRST],
	[false, false, true, EXIT_SECOND],
]

var _state_first: FiniteState
var _state_second: FiniteState


func before_test() -> void:
	_state_first = auto_free(FiniteState.new())
	_state_first.name = "StateFirst"
	_state_second = auto_free(FiniteState.new())
	_state_second.name = "StateSecond"


## A nested condition can transition when the parent or any child passes;
## a passing parent with no passing child still reports it can transition,
## which the machine then resolves to no exit.
func test_nested_can_transition(
	parent_passes: bool,
	child1_passes: bool,
	child2_passes: bool,
	expected: bool,
	_test_parameters := CAN_TRANSITION_CASES,
) -> void:
	var parent := _build_nested(parent_passes, child1_passes, child2_passes)

	assert_bool(parent.can_transition()).is_equal(expected)


## The exit node resolves to the first passing child's exit; a failing child
## falls through to the next sibling.
func test_nested_resolves_first_passing_exit(
	parent_passes: bool,
	child1_passes: bool,
	child2_passes: bool,
	expected_exit: int,
	_test_parameters := EXIT_CASES,
) -> void:
	var parent := _build_nested(parent_passes, child1_passes, child2_passes)

	var exit_node := parent.get_exit_node()
	match expected_exit:
		EXIT_FIRST:
			assert_object(exit_node).is_same(_state_first)
		EXIT_SECOND:
			assert_object(exit_node).is_same(_state_second)


func _build_nested(
	parent_passes: bool,
	child1_passes: bool,
	child2_passes: bool,
) -> TransitionCondition:
	var parent: TransitionCondition = auto_free(TransitionCondition.new())
	parent.condition = _make_condition(parent_passes)
	parent.add_child(_make_child(child1_passes, _state_first))
	parent.add_child(_make_child(child2_passes, _state_second))
	return parent


func _make_child(passes: bool, exit_state: FiniteState) -> TransitionCondition:
	var child := TransitionCondition.new()
	child.condition = _make_condition(passes)
	var exit := TransitionExit.new()
	exit.exit_node = exit_state
	child.add_child(exit)
	return child


func _make_condition(passes: bool) -> MockCondition:
	var condition := MockCondition.new()
	condition.should_pass = passes
	return condition


class MockCondition:
	extends TransitionOnCondition

	var should_pass: bool = false

	func _can_transition() -> bool:
		return should_pass
