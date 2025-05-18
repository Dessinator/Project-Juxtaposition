@tool
extends FSMState

@export var _velocity_retained_percentage: float = 0.0

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var velocity = actor.velocity * _velocity_retained_percentage
	actor.velocity = velocity
	
	var character_attack_state_machine = actor.get_character_attack_state_machine()
	
	character_attack_state_machine.neutral_state_entered.connect(_on_neutral_state_entered.bind(blackboard))

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var character_attack_state_machine = actor.get_character_attack_state_machine()
	
	character_attack_state_machine.neutral_state_entered.disconnect(_on_neutral_state_entered)

func _on_neutral_state_entered(blackboard: BTBlackboard):
	_handle_transition_events(blackboard)

#func _on_light_attack_ended(blackboard: BTBlackboard):
	#_handle_transition_events(blackboard)
#
func _handle_transition_events(blackboard: BTBlackboard):
	if Input.is_action_pressed("move"):
		if Input.is_action_pressed("sprint"):
			get_parent().fire_event("on_start_sprinting")
			return
		
		if not blackboard.get_value("auto_jog"):
			get_parent().fire_event("on_start_walking")
		else:
			get_parent().fire_event("on_start_jogging")
		return 
	
	get_parent().fire_event("on_start_idling")
	return
