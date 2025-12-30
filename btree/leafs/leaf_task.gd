@abstract
class_name BT_LeafTask
extends BT_BaseTask
## Leaf tasks are the final nodes that a [BehaviorTree] ends on. This should
## handle the concrete behaviors of the tasks.
##
## Leaf nodes are the terminal nodes in a behavior tree - they have no children
## and represent concrete actions or conditions that can be executed.
## They are called "leaf" nodes because they sit at the ends of branches
## in the tree structure.
## [br][br]
## * Leaf nodes always return a status: SUCCESS, FAILURE, or RUNNING
## [br]
## * They interact directly with the game world or check game state
## [br]
## * They have no child nodes
## [br]
## * They are where the "real work" happens in your behavior tree
##
## @tutorial(Beehave Reference): https://bitbra.in/beehave/#/manual/leaf_nodes
