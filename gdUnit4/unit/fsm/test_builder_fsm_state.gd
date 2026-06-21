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
