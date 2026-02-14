@abstract
@icon("res://addons/show_not_tell/icons/category_composite.svg")
class_name BT_CompositeTask
extends BT_BaseTask
## Intermediary tasks of the [BehaviorTree] that lead to a [BT_LeafTask].
##
## Composite nodes are essential components of Behavior Trees, allowing
## you to create logic flows by combining conditions and actions.
## A composite node is a parent node that executes its children in a
## specific order, helping to define complex behaviors for your game
## characters or objects.
##
## @tutorial(Beehave Reference): https://bitbra.in/beehave/#/manual/composites

var current_child_index: int = 0
var shuffled_children: Array[BT_BaseTask] = []


func _reset_child_index() -> void:
	current_child_index = 0


func _shuffle_and_reset() -> void:
	current_child_index = 0
	shuffled_children = child_tasks.duplicate()
	shuffled_children.shuffle()


func _clear_shuffle() -> void:
	current_child_index = 0
	shuffled_children.clear()
