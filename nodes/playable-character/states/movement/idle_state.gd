@tool
extends PlayableCharacterGameplayState

const IS_TARGETING: String = "is_targeting"
const TRACKED_TARGET_POSITION: String = "tracked_target_position"

@onready var _stamina_regeneration_delay_timer: Timer = %StaminaRegenerationDelayTimer

func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	
	_handle_stamina_regeneration_delay(blackboard)

func _on_update(_delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	_handle_targeting(actor, blackboard)

func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	_stamina_regeneration_delay_timer.timeout.disconnect(_on_stamina_regeneration_delay_timer_timeout)
	pass

func _handle_targeting(actor: PlayableCharacter, blackboard: BTBlackboard):
	var character_animation_tree_expression_base = _character.get_node("%CharacterAnimationTreeExpressionBase")
	
	if not blackboard.get_value(IS_TARGETING):
		character_animation_tree_expression_base.travel_to_non_targeting_movement()
		return
	
	var tracked_target_position = blackboard.get_value(TRACKED_TARGET_POSITION)
	if tracked_target_position == null:
		return
	character_animation_tree_expression_base.travel_to_targeting_movement()
	var direction = tracked_target_position - actor.global_position
	var rotation = atan2(direction.x, direction.z)
	_playable_character_character_container.rotation.y = rotation

#func _handle_stamina_regen_delay(status: CharacterStatus):
	#var stamina = status.get_stamina()
	#var max_stamina = status.get_max_stamina()
	#
	#if stamina >= max_stamina:
		#return
	#
	#if _stamina_regen_delay_timer.is_stopped():
		#_stamina_regen_delay_timer.timeout.connect(_handle_stamina_regen)
		#_stamina_regen_delay_timer.start()

func _handle_stamina_regeneration_delay(blackboard: BTBlackboard):
	_stamina_regeneration_delay_timer.timeout.connect(_on_stamina_regeneration_delay_timer_timeout.bind(blackboard))
	if not blackboard.get_value("regenerate_stamina") and _stamina_regeneration_delay_timer.is_stopped():
		blackboard.set_value("regenerate_stamina", false)
		_stamina_regeneration_delay_timer.start()

func _on_stamina_regeneration_delay_timer_timeout(blackboard: BTBlackboard):
	blackboard.set_value("regenerate_stamina", true)
