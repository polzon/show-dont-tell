@abstract
@icon("res://addons/show_not_tell/icons/sequence.svg")
class_name BT_SequenceComposite
extends BT_CompositeTask
## The Sequence node is a fundamental building block in Behavior Trees,
## used to execute a series of child nodes in a specific order. It helps
## you define the order of actions or tasks that your game characters
## or objects will follow.
##
## The Sequence node tries to execute all its children one by one, in the
## order they are connected. It reports a SUCCESS status code if all
## children report SUCCESS. If at least one child reports a FAILURE
## status code, the Sequence node also returns FAILURE.
##
## @tutorial(Beehave Reference): https://bitbra.in/beehave/#/manual/sequence
