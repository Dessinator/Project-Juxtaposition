@tool
extends FSMTransition

@onready var _arial_dodge_state: FSMState = %ArialDodgeState

# Executed when the transition is taken.
func _on_transition(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, blackboard: BTBlackboard) -> bool:
	actor = actor as PlayableCharacter
	
	var can_arial_dodge = blackboard.get_value("can_arial_dodge")
	
	if not can_arial_dodge:
		return false
	
	var character_container = actor.get_playable_character_character_container()
	var character = character_container.get_current_character()
	var status = character.get_character_status()
	var stamina_drain = _arial_dodge_state.get_stamina_drain()
	var stamina = status.get_stamina()
	
	if stamina - stamina_drain < 0:
		return false
	
	return Input.is_action_just_pressed("dodge")
