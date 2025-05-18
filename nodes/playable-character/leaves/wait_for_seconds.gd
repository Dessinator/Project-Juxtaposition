@tool
extends BTLeaf

@export var _time_seconds: float = 1.0
var _timer: float

# Gets called every tick of the behavior tree
func tick(delta: float, _actor: Node, _blackboard: BTBlackboard) -> BTStatus:
	_timer -= delta
	
	if _timer <= 0.0:
		
		return BTStatus.SUCCESS
	return BTStatus.RUNNING
