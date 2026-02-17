class_name GOAPWorldState
extends RefCounted
## World state for GOAP planning. Stores key-value pairs representing
## the current or desired state of the world.
## Keys are StringName for performance, values are Variant for flexibility.

var _state: Dictionary = {}


func _init(initial_state: Dictionary = {}) -> void:
	_state = initial_state.duplicate()


## Set a state variable
func set_value(key: StringName, value: Variant) -> void:
	_state[key] = value


## Get a state variable, returns null if not found
func get_value(key: StringName, default: Variant = null) -> Variant:
	return _state.get(key, default)


## Check if a key exists in the state
func has(key: StringName) -> bool:
	return _state.has(key)


## Remove a key from the state
func erase(key: StringName) -> void:
	_state.erase(key)


## Clear all state
func clear() -> void:
	_state.clear()


## Get all keys in the state
func get_keys() -> Array[StringName]:
	var keys: Array[StringName] = []
	keys.assign(_state.keys())
	return keys


## Create a shallow copy of this world state
func duplicate() -> GOAPWorldState:
	return GOAPWorldState.new(_state.duplicate())


## Check if this state satisfies all requirements in target state.
## Returns true if all key-value pairs in target exist in this state
## with matching values.
func satisfies(target: GOAPWorldState) -> bool:
	for key: StringName in target.get_keys():
		if not has(key):
			return false
		if get_value(key) != target.get_value(key):
			return false
	return true


## Apply effects from another state to this state
func apply_effects(effects: GOAPWorldState) -> void:
	for key: StringName in effects.get_keys():
		set_value(key, effects.get_value(key))


## Get the raw dictionary (for debugging/serialization)
func to_dict() -> Dictionary:
	return _state.duplicate()


## String representation for debugging
func _to_string() -> String:
	return str(_state)
