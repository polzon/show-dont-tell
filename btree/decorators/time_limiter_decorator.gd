@icon("res://addons/show_not_tell/icons/limiter.svg")
class_name BT_TimeLimiterDecorator
extends BT_DecoratorTask
## The TimeLimiter node only gives its RUNNING child a set amount of time
## to finish.
##
## When the time is up, it interrupts its child and returns
## a FAILURE status code. The time limiter resets its time after
## its child returns either SUCCESS or FAILURE.
