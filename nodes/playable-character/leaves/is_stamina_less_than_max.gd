@tool
extends BTLeaf


# Gets called every tick of the behavior tree
func tick(_delta: float, actor: Node, _blackboard: BTBlackboard) -> BTStatus:
	actor = actor as PlayableCharacter
	
	var status = actor.get_status()
	var stamina = status.get_stamina()
	var max_stamina = status.get_max_stamina()
	
	if stamina < max_stamina:
		return BTStatus.SUCCESS
	return BTStatus.FAILURE
