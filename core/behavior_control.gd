@abstract
class_name BehaviorControl
extends Node
## Abstract control point that BehaviorTree and StateMachine are
## extended from.


func _process(_delta: float) -> void:
	set_process(false)


func _physics_process(_delta: float) -> void:
	set_physics_process(false)


@abstract func handle_action(action: Action) -> void
