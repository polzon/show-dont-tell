class_name GdBuilderFsmState
extends RefCounted

var _root: FiniteState


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_root.free()


func create_state(data_script: GDScript = null) -> GdBuilderFsmState:
	_root = FiniteState.new()
	if data_script:
		_set_state_data(_root, data_script)
	return self


func _set_state_data(state: FiniteState, data_script: GDScript) -> void:
	if not data_script or not data_script.can_instantiate():
		return

	if state:
		var data_obj: Variant = data_script.new()
		if data_obj is StateData:
			state.state_data = data_obj
		elif data_obj is not RefCounted:
			data_obj.free()


func build() -> FiniteState:
	return _root
