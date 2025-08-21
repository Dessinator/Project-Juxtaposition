@tool
extends FSMTransition

# handles the transition from * -> light_attack

func is_valid(actor: Node, _blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	return Input.is_action_just_pressed("light_attack")
