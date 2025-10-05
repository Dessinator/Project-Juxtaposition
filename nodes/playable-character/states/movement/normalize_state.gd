@tool
extends PlayableCharacterGameplayState

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var character_container = actor.get_playable_character_character_container()
	var character = character_container.get_current_character()
	var status = character.get_character_status()
	status.set_is_juxtaposed(false)
	status.set_immune(false)
	
	_handle_transitions(actor, blackboard)


# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)

func _handle_transitions(actor: PlayableCharacter, blackboard: BTBlackboard):
	if not actor.is_on_floor():
		get_parent().fire_event(ON_START_FALLING)
		return
	
	if not Input.is_action_pressed("move"):
		get_parent().fire_event(ON_START_IDLING)
		return
	
	var character_container = actor.get_playable_character_character_container()
	var current_character = character_container.get_current_character()
	var status = current_character.get_character_status()
	
	if Input.is_action_pressed("sprint") and (not status.is_exhausted()):
		get_parent().fire_event(ON_START_SPRINTING)
		return
	
	if blackboard.get_value(AUTO_JOG):
		get_parent().fire_event(ON_START_JOGGING)
		return
	
	get_parent().fire_event(ON_START_WALKING)
