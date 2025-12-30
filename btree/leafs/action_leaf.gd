@abstract
class_name BT_ActionLeaf
extends BT_LeafTask
## The ActionLeaf node is a key element in Behavior Trees, designed to
## represent ACTIONS that game characters or objects perform, such as gathering
## wood or fishing. As leaf nodes, they don't have any children and are
## responsible for executing the specific task in the game.
##
## ActionLeaf nodes should return a custom user value depending on the result
## of the action. Since actions can potentially span across multiple frames,
## they should return RUNNING when the action is still being executed.
## [br][br]
## When the action is completed successfully, the ActionLeaf node should return
## SUCCESS. If the action fails or is interrupted, it should return FAILURE.
##
## @tutorial(Beehave Reference): https://bitbra.in/beehave/#/manual/action_leaf
