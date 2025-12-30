class_name BT_UntilFailDecorator
extends BT_DecoratorTask
## The UntilFail node executes its child and returns RUNNING as long as it
## returns either RUNNING or SUCCESS. If its child returns FAILURE,
## it will instead return SUCCESS.
