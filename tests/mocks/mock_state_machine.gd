class_name MockStateMachine
extends StateMachine
## Mock [StateMachine] for testing [FiniteState] components.


func _ready() -> void:
	# Don't warn about missing initial state
	pass


func _process(delta: float) -> void:
	if state and enabled:
		state._tick(delta)


func _physics_process(delta: float) -> void:
	if state and enabled:
		state._physics_tick(delta)
