class_name MockStateMachine
extends StateMachine
## Mock StateMachine for testing State components.


func _ready() -> void:
	# Don't warn about missing initial state
	pass


func _process(_delta: float) -> void:
	if state and enabled:
		state._tick(_delta)


func _physics_process(_delta: float) -> void:
	if state and enabled:
		state._physics_tick(_delta)
