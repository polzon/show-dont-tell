class_name CommandQueue
extends RefCounted
## Simple queue to store and process [Command] commands for a target node.

signal handle_command(command: Command)

var pending_commands: Array[Command] = []
## Max size for [member _command_queue]. Set to 0 or lower to disable the limit.
var queue_limit: int = 0
var target: Node


func _init(parent_target: Node) -> void:
	target = parent_target


func act(command: Command) -> void:
	if queue_limit > 0:
		while pending_commands.size() > queue_limit:
			pending_commands.remove_at(0)
	pending_commands.push_back(command)


func process_queue() -> void:
	while not pending_commands.is_empty():
		var command: Command = pending_commands.pop_back()
		handle_command.emit(command)
		command.perform()
