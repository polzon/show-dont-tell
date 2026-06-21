extends GdUnitTestSuite


func test_state_creation_valid() -> void:
	var builder := GdBuilderFsmState.new()
	builder.create_state(StateDataMove)
	var root := builder.build()
	add_child(root)

	assert_object(root).is_not_null()
	assert_object(root.state_data).is_not_null()


func test_state_creation_invalid(
	wrong_type: Variant, _test_parameters := [[null], [FiniteState]]
) -> void:
	var builder := GdBuilderFsmState.new()
	var wrong_script: GDScript = wrong_type
	builder.create_state(wrong_script)
	var root := builder.build()
	add_child(root)

	assert_object(root).is_not_null()
	assert_object(root.state_data).is_null()


func test_add_condition_valid() -> void:
	var builder := GdBuilderFsmState.new()
	builder.create_state(StateDataMove)
	builder.create_condition(TransitionOnCommand)
	var root := builder.build()
	add_child(root)

	assert_object(root).is_not_null()
	assert_int(root.get_child_count()).is_equal(1)
	var condition_node := root.get_child(0) as TransitionCondition
	assert_object(condition_node).is_not_null()
	assert_object(condition_node.condition).is_not_null()
