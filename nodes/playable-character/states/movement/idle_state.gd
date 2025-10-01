@tool
extends PlayableCharacterGameplayState

func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)

func _on_update(_delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	_handle_targeting(actor, blackboard)

func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
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
