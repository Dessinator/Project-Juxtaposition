@tool
extends FSMTransition

# handles the transition from * -> jogging

func is_valid(actor: Node, blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	if not actor.is_on_floor():
		return false
		
	if not blackboard.get_value("auto_jog"):
		return false
	
	if Input.is_action_pressed("sprint") and (not actor.get_status().is_exhausted()):
		return false
	
	return Input.is_action_pressed("move")
