@icon("res://addons/show_not_tell/icons/cooldown.svg")
class_name BT_CooldownDecorator
extends BT_DecoratorTask
## The Cooldown node executes its child until it either returns SUCCESS
## or FAILURE, after which it will start an internal timer and return
## FAILURE until the timer is complete. The cooldown is then able
## to execute its child again.
