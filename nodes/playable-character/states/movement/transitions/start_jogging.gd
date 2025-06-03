@tool
extends FSMTransition

# handles the transition from * -> jogging

func is_valid(actor: Node, blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	if not actor.is_on_floor():
		return false
		
	if blackboard.get_value("auto_jog"):
		if blackboard.get_value("is_targeting"):
			var direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
			if direction.y > 0:
				return false
	else:
		return false
	
	if Input.is_action_pressed("sprint") and (not actor.get_status().is_exhausted()):
		return false
	
	return Input.is_action_pressed("move")
