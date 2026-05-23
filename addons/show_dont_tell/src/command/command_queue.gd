class_name CommandQueue
extends RefCounted
## Simple queue to store and process [Command] commands for a target node.

signal handle_action(command: Command)

var pending_actions: Array[Command] = []
## Max size for [member _action_queue]. Set to 0 or lower to disable the limit.
var queue_limit: int = 0
var target: Node


func _init(parent_target: Node) -> void:
	target = parent_target
	target.ready.connect(_on_target_ready)


func _on_target_ready() -> void:
	assert(target, "Target is invalid.")

	# State Machine
	var fsm := StateMachine.find_state_machine(target)
	if (
		is_instance_valid(fsm)
		and not handle_action.is_connected(fsm.handle_action)
	):
		handle_action.connect(fsm.handle_action)

	# Behavior Tree
	var btree := BehaviorTree.find_behavior_tree(target)
	if (
		is_instance_valid(btree)
		and not handle_action.is_connected(btree.handle_action)
	):
		handle_action.connect(btree.handle_action)


func act(command: Command) -> void:
	if queue_limit > 0:
		while pending_actions.size() > queue_limit:
			pending_actions.remove_at(0)
	pending_actions.push_back(command)


func process_queue() -> void:
	while not pending_actions.is_empty():
		var command: Command = pending_actions.pop_back()
		handle_action.emit(command)
		command.perform()
