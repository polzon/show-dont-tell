@abstract class_name TransitionRule
extends Resource

## The node that the transition will exit to.
var exit_node: FiniteState

## Checks if a transition can be performed.
@abstract func can_transition() -> bool
