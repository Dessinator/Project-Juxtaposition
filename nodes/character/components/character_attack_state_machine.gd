@tool
class_name CharacterAttackStateMachine
extends FiniteStateMachine

var _character: Character

@onready var _character_combo: CharacterCombo = _character.get_character_combo()
@onready var _character_attack_definition_manager: CharacterAttackDefinitionManager = _character.get_character_attack_definition_manager()
