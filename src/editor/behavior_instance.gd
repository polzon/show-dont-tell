class_name BehaviorInstance
extends RefCounted

## Tha singleton.
static var _instance: BehaviorInstance:
	get():
		if not instance:
			_instance = BehaviorInstance.new()
		return _instance


## Returns a reference to the singleton.
static func instance() -> BehaviorInstance:
	return _instance
