class_name BT_SelectorComposite
extends BT_CompositeTask
## The Selector node is another fundamental building block in Behavior Trees,
## used to manage decision-making among multiple child nodes.
## It helps you define different behaviors for your game characters or
## objects based on varying conditions.
##
## The Selector node tries to execute each of its children one by one,
## in the order they are connected. It reports a SUCCESS status code if any
## child reports a SUCCESS. If all children report a FAILURE status code,
## the Selector node also returns FAILURE.
##
## @tutorial(Beehave Reference): https://bitbra.in/beehave/#/manual/selector
