@tool
extends FSMTransition

# handles the transition from * -> grounded dodge

@onready var _dodge_state: Node = %GroundedDodgeState

# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	var character_container = actor.get_playable_character_character_container()
	var character = character_container.get_current_character()
	var status = character.get_character_status()
	var stamina_drain = _dodge_state.get_stamina_drain()
	var stamina = status.get_stamina()
	
	if stamina - stamina_drain < 0:
		return false
	
	return Input.is_action_just_pressed("dodge")
