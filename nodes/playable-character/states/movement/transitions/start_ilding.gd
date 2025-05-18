@tool
extends FSMTransition

# handles the transition from * -> idling

func _on_transition(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func is_valid(actor: Node, _blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	if not actor.is_on_floor():
		return false
	
	if not actor.velocity.is_zero_approx():
		return false
	
	return not Input.is_action_pressed("move")
