class_name MockCondition
extends BT_ConditionLeaf
## Mock [BT_ConditionLeaf] for testing [BehaviorTree] condition logic.
##
## Allows tests to configure a return status and track execution count.

# ? Can probably be removed and replaced with mock() in unit tests.

enum ConfigMode { ALWAYS_SUCCESS, ALWAYS_FAILED, TOGGLE }

var configured_status: Status = SUCCESS
var execution_count: int = 0
var config_mode: ConfigMode = ConfigMode.ALWAYS_SUCCESS
var toggle_count: int = 0


func _tick(_delta: float) -> Status:
	execution_count += 1

	match config_mode:
		ConfigMode.ALWAYS_SUCCESS:
			return SUCCESS
		ConfigMode.ALWAYS_FAILED:
			return FAILED
		ConfigMode.TOGGLE:
			toggle_count += 1
			if toggle_count % 2 == 1:
				return SUCCESS
			return FAILED
		_:
			return configured_status


func set_always_success() -> void:
	config_mode = ConfigMode.ALWAYS_SUCCESS
	configured_status = SUCCESS


func set_always_failed() -> void:
	config_mode = ConfigMode.ALWAYS_FAILED
	configured_status = FAILED


func set_toggle_mode() -> void:
	config_mode = ConfigMode.TOGGLE
	toggle_count = 0


func reset_execution_count() -> void:
	execution_count = 0
	toggle_count = 0
