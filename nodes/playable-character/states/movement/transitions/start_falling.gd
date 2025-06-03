@tool
extends FSMTransition

# handles the transition from * -> falling

func _on_transition(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func is_valid(actor: Node, _blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	var last_slide_collision = actor.get_last_slide_collision()
	if last_slide_collision:
		return false
	
	return not actor.is_on_floor()
