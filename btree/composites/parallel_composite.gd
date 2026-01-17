@icon("res://addons/show_not_tell/icons/simple_parallel.svg")
class_name BT_ParallelComposite
extends BT_CompositeTask
## The Simple Parallel node is a fundamental building block in Behavior Trees,
## used to execute two children at the same time. It helps you run
## multiple actions simultaneously. Think of the Simple Parallel node
## as "While doing A, do B as well".
##
## Simple Parallel nodes will attempt to execute all children at the same
## time and can only have exactly two children. First child as the primary
## node, second child as the secondary node. This node will always report the
## primary node's state, and continue ticking while the primary node returns
## RUNNING. The state of the secondary node will be ignored and executed
## like a subtree. If the primary node returns SUCCESS or FAILURE, this node
## will interrupt the secondary node and return the primary node's result.
## If this node is running under delay mode, it will wait for the
## secondary node to finish its action after the primary node terminates.
##
## @tutorial(Beehave Reference): https://bitbra.in/beehave/#/manual/simple_parallel


func _tick(_delta: float) -> Status:
	return Status.FAILED
