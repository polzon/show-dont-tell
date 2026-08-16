extends GdUnitTestSuite

## Command handling forwards through the state tree to state_data unless a
## condition consumes the command first. Each row seeds a tree topology and
## pins where the command ends up.
## Rows: [has_state_data, topology, reaches_state_data, consumed].
enum Topology {
	NO_CHILDREN,
	CONDITION,
	CONDITION_WITH_EXIT,
	CONSUMING_CONDITION,
}

const COMMAND_CASES: Array[Array] = [
	[false, Topology.NO_CHILDREN, false, false],
	[false, Topology.CONDITION, false, false],
	[true, Topology.NO_CHILDREN, true, false],
	[true, Topology.CONDITION, true, false],
	[true, Topology.CONDITION_WITH_EXIT, true, false],
	[true, Topology.CONSUMING_CONDITION, false, true],
]


func test_handle_command_case(
	has_state_data: bool,
	topology: int,
	reaches_state_data: bool,
	consumed: bool,
	_test_parameters := COMMAND_CASES,
) -> void:
	var machine: StateMachine = auto_free(StateMachine.new())
	var state: TestPropagationState = auto_free(TestPropagationState.new())
	var command := TestCommand.new()

	var state_data := TestStateData.new()
	if has_state_data:
		state.state_data = state_data
	_build_topology(state, topology)
	machine.state = state

	machine.handle_command(command)

	assert_that(state.handle_command_called).is_true()
	assert_int(state.handle_command_call_count).is_equal(1)
	if has_state_data:
		if reaches_state_data:
			assert_that(state_data.last_command).is_same(command)
		else:
			assert_that(state_data.last_command).is_null()
	assert_that(command.is_consumed()).is_equal(consumed)


func _build_topology(state: TestPropagationState, topology: int) -> void:
	match topology:
		Topology.NO_CHILDREN:
			pass
		Topology.CONDITION:
			state.add_child(TransitionCondition.new())
		Topology.CONDITION_WITH_EXIT:
			var condition := TransitionCondition.new()
			condition.add_child(TransitionExit.new())
			state.add_child(condition)
		Topology.CONSUMING_CONDITION:
			var condition := TransitionCondition.new()
			condition.condition = TestConsumingCondition.new()
			state.add_child(condition)


class TestPropagationState:
	extends FiniteState

	var handle_command_called: bool = false
	var handle_command_call_count: int = 0

	func _handle_command(command: Command) -> void:
		handle_command_called = true
		handle_command_call_count += 1
		super._handle_command(command)


class TestStateData:
	extends StateData

	var last_command: Command

	func handle_command(command: Command) -> void:
		last_command = command


class TestCommand:
	extends Command


class TestConsumingCondition:
	extends TransitionOnCondition

	func handle_command(command: Command) -> bool:
		if command:
			command.consume()
			return true
		return false

	func _can_transition() -> bool:
		return false
