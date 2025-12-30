@abstract
class_name BT_ConditionLeaf
extends BT_LeafTask
## A ConditionLeaf node is employed to facilitate decision-making behaviors
## within a behavior tree. It assesses a user-defined condition and
## returns a status based on the evaluation outcome. If the condition is true,
## the ConditionLeaf returns a SUCCESS status. Conversely, if the condition is
## false, the ConditionLeaf returns a FAILURE status. The Condition Leaf is
## versatile and can be utilized to evaluate a wide array of conditions,
## including the proximity of an enemy, the availability of a particular item,
## or the health of the player character.
##
## The ConditionLeaf returns a status code that indicates whether the
## condition is true or false.
##
## @tutorial(Beehave Reference): https://bitbra.in/beehave/#/manual/condition_leaf
