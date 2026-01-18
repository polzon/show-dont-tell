@abstract
class_name BaseState
extends Node
## The origin node that all behavior derrives from.

# [Dev Note]
# This script is intended to be used as the base for both Behavior Tree and
# the State Machine. Including the state machines and states themselves.

## Emitted when the [BaseState] has been entered/started.
signal started
## Emitted when the [BaseState] has been exited/stopped.
signal ended

## If set to `true`, the processing will be automatically toggled off or on
## when the state is changed. It will automatically toggle [method _process]
## and [method _physics_process] if they are overwritten and enabled
## in the node file. By default, both are `false`.
var process_on_active: bool = _is_any_processing_enabled():
	set = set_process_on_active


func set_process_on_active(is_enabled: bool) -> void:
	process_on_active = is_enabled
	_setup_physics_signal(process_on_active)
	_setup_process_signal(process_on_active)


## Processed when the [BaseState] has been entered.
func _entered_state() -> void:
	started.emit()


## Processed when the [BaseState] has exited.
func _exited_state() -> void:
	ended.emit()


func _setup_process_signal(is_enabled: bool) -> void:
	if has_method("_process"):
		if is_enabled:
			if not started.is_connected(set_process.bind(true)):
				started.connect(set_process.bind(true))
			if not ended.is_connected(set_process.bind(false)):
				ended.connect(set_process.bind(false))
		else:
			if started.is_connected(set_process.bind(true)):
				started.disconnect(set_process.bind(true))
			if ended.is_connected(set_process.bind(false)):
				ended.disconnect(set_process.bind(false))


func _setup_physics_signal(is_enabled: bool) -> void:
	if has_method("_physics_process"):
		if is_enabled:
			if not started.is_connected(set_physics_process.bind(true)):
				started.connect(set_physics_process.bind(true))
			if not ended.is_connected(set_physics_process.bind(false)):
				ended.connect(set_physics_process.bind(false))
		else:
			if started.is_connected(set_physics_process.bind(true)):
				started.disconnect(set_physics_process.bind(true))
			if ended.is_connected(set_physics_process.bind(false)):
				ended.disconnect(set_physics_process.bind(false))


## Returns if *either* [method _process] or [method _physics_processing] are
## overwritten and enabled in the script.
func _is_any_processing_enabled() -> bool:
	var processing_enabled := \
			has_method("_process") \
			or has_method("_physics_process")
	set_process_on_active(processing_enabled)
	return processing_enabled
