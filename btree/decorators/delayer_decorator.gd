class_name BT_DelayerDecorator
extends BT_DecoratorTask
## When first executing the Delayer node, it will start an internal timer
## and return RUNNING until the timer is complete, after which it will
## execute its child node. The delayer resets its time after its
## child returns either SUCCESS or FAILURE.
