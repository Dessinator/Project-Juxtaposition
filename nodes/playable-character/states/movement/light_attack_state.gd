@tool
extends PlayableCharacterGameplayState

const LIGHT_ATTACK_TYPE_STRING: StringName = &"light_attack"

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	var character_combo = _character.get_character_combo()
	blackboard.set_value("character_combo", character_combo)
	var current_attack_internal_name = blackboard.get_value("character_combo_current_attack_internal_name")
	
	var next_attack_internal_name = character_combo.get_next_attack_id(current_attack_internal_name, LIGHT_ATTACK_TYPE_STRING)
	var character_attack_definition_manager = _character.get_character_attack_definition_manager()
	var next_attack_definition = character_attack_definition_manager.get_character_attack_definition(next_attack_internal_name)
	blackboard.set_value("character_combo_current_attack_internal_name", next_attack_internal_name)
	print(next_attack_definition.get_readable_name())
	
# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: BTBlackboard) -> void:
	pass
