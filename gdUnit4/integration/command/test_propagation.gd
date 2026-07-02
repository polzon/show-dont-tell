extends GdUnitTestSuite


func test_handle_command_propagates_to_state_data() -> void:
	var machine: StateMachine = auto_free(StateMachine.new())
	var state: MockState = auto_free(MockState.new())
	var state_data := MockStateData.new()
	var command := MockCommand.new()

	state.state_data = state_data
	machine.state = state

	machine.handle_command(command)

	assert_that(state.handle_command_called).is_true()
	assert_int(state.handle_command_call_count).is_equal(1)
	assert_that(state_data.last_command).is_same(command)


func test_handle_command_propagates_to_state_data_with_no_state_data() -> void:
	var machine: StateMachine = auto_free(StateMachine.new())
	var state: MockState = auto_free(MockState.new())
	var command := MockCommand.new()

	machine.state = state

	machine.handle_command(command)

	assert_that(state.handle_command_called).is_true()
	assert_int(state.handle_command_call_count).is_equal(1)


func test_handle_command_propagates_condition_node() -> void:
	var machine: StateMachine = auto_free(StateMachine.new())
	var state: MockState = auto_free(MockState.new())
	var condition_node := TransitionCondition.new()
	var command := MockCommand.new()

	state.add_child(condition_node)
	machine.state = state

	machine.handle_command(command)

	assert_that(state.handle_command_called).is_true()
	assert_int(state.handle_command_call_count).is_equal(1)


func test_handle_command_propagates_to_state_data_with_condition_node() -> void:
	var machine: StateMachine = auto_free(StateMachine.new())
	var state: MockState = auto_free(MockState.new())
	var state_data := MockStateData.new()
	var condition_node := TransitionCondition.new()
	var command := MockCommand.new()

	state.state_data = state_data
	state.add_child(condition_node)
	machine.state = state

	machine.handle_command(command)

	assert_that(state.handle_command_called).is_true()
	assert_int(state.handle_command_call_count).is_equal(1)
	assert_that(state_data.last_command).is_same(command)


func test_handle_propagates_to_state_data_with_condition_node_then_exit_node(
) -> void:
	var machine: StateMachine = auto_free(StateMachine.new())
	var state: MockState = auto_free(MockState.new())
	var state_data := MockStateData.new()
	var condition_node := TransitionCondition.new()
	var exit_node := TransitionExit.new()
	var command := MockCommand.new()

	state.state_data = state_data
	state.add_child(condition_node)
	condition_node.add_child(exit_node)
	machine.state = state

	machine.handle_command(command)

	assert_that(state.handle_command_called).is_true()
	assert_int(state.handle_command_call_count).is_equal(1)
	assert_that(state_data.last_command).is_same(command)
