extends GdUnitTestSuite
## Unit tests for [GdBuilderFsmState].
## [br]
## Link: 'res://addons/show_dont_tell/gdUnit4/builders/gd_builder_fsm_state.gd'


func test_state_creation_valid() -> void:
	var builder := GdBuilderFsmState.new_state(StateDataMove)
	assert_object(builder).is_not_null()

	var root: FiniteState = auto_free(builder.get_root())
	add_child(root)

	assert_object(root).is_not_null()
	assert_object(root.state_data).is_not_null()


func test_state_creation_invalid(
	wrong_type: Variant, _test_parameters := [[null], [FiniteState]]
) -> void:
	var wrong_script: GDScript = wrong_type
	var builder := GdBuilderFsmState.new_state(wrong_script)
	var root: FiniteState = auto_free(builder.get_root())
	add_child(root)

	assert_object(root).is_not_null()
	assert_object(root.state_data).is_null()


func test_add_condition_valid() -> void:
	var builder := GdBuilderFsmState.new_state(StateDataMove).if_condition(
		TransitionOnCommand
	)
	var root: FiniteState = auto_free(builder.get_root())
	add_child(root)

	assert_object(root).is_not_null()
	assert_int(root.get_child_count()).is_equal(1)
	var condition_node := root.get_child(0) as TransitionCondition
	assert_object(condition_node).is_not_null()
	assert_object(condition_node.condition).is_not_null()


func test_create_condition_exit() -> void:
	var first_builder := GdBuilderFsmState.new_state(StateDataIdle)
	var first_root: FiniteState = auto_free(first_builder.get_root())
	add_child(first_root)

	var second_builder := (
		GdBuilderFsmState
		. new_state(StateDataIdle)
		. if_condition(TransitionOnCommand)
		. exit_to(first_root)
	)
	var second_root: FiniteState = auto_free(second_builder.get_root())
	add_child(second_root)

	var nodes := second_builder.get_all_nodes()
	assert_array(nodes).is_not_empty()
	assert_array(nodes).has_size(3)

	var state_count := _state_count(nodes)
	var condition_count := _condition_count(nodes)
	var exit_count := _exit_count(nodes)
	(
		assert_int(state_count)
		. is_equal(condition_count)
		. is_equal(exit_count)
		. is_equal(1)
	)


func _state_count(data_arr: Array) -> int:
	return (
		data_arr
		. filter(func(v: Variant) -> bool: return v is FiniteState)
		. size()
	)


func _condition_count(data_arr: Array) -> int:
	return (
		data_arr
		. filter(func(v: Variant) -> bool: return v is TransitionCondition)
		. size()
	)


func _exit_count(data_arr: Array) -> int:
	return (
		data_arr
		. filter(func(v: Variant) -> bool: return v is TransitionExit)
		. size()
	)
