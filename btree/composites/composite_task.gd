@abstract
@icon("res://addons/show_not_tell/icons/category_composite.svg")
class_name BT_CompositeTask
extends BT_BaseTask
## An intermediary tasks that make up the branches for the [BehaviorTree]
## to eventually lead to a [BT_LeafTask].
##
## Composite nodes are essential components of Behavior Trees, allowing
## you to create logic flows by combining conditions and actions.
## A composite node is a parent node that executes its children in a
## specific order, helping to define complex behaviors for your game
## characters or objects.
##
## @tutorial(Beehave Reference): https://bitbra.in/beehave/#/manual/composites
