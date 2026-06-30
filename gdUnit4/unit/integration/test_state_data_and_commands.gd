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
