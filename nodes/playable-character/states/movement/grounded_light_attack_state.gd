@tool
extends PlayableCharacterGameplayState

@onready var _playable_character_combat_manager: PlayableCharacterCombatManager = %PlayableCharacterCombatManager

@export var _damage_multiplier: float = 0.25

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	var tracked_target = _playable_character_combat_manager.get_tracked_target()
	if tracked_target == null:
		_handle_transitions(actor, blackboard)
		return
	
	var target_node = tracked_target.get_parent()
	var status_interface = target_node.get_node("%StatusInterface") as StatusInterface
	if status_interface == null:
		_handle_transitions(actor, blackboard)
		return
	
	_playable_character_combat_manager.deal_damage(status_interface, _damage_multiplier)
	
	actor.velocity = Vector3.ZERO
	await get_tree().create_timer(0.5).timeout
	
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
