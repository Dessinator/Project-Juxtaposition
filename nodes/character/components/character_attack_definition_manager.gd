class_name CharacterAttackDefinitionManager
extends Node

# responsible for holding a character's AttackDefinitions

@export var _character_attack_definitions: Array[CharacterAttackDefinition]

var _character_attack_definitions_dictionary: Dictionary = {}

func _ready():
	_populate_dictionary()

func _populate_dictionary():
	# Populate the dictionary for O(1) access time.
	for character_attack_definition in _character_attack_definitions:
		var internal_name = character_attack_definition.get_internal_name()
		assert(not internal_name.is_empty(), "CharacterAttackDefinition on Character {character_name} is missing an internal name.".format({"character_name": get_parent().name}))
		_character_attack_definitions_dictionary[internal_name] = character_attack_definition

# Returns a specific CharacterAttackDefinition resource based on its ID.
func get_character_attack_definition(character_attack_definition_internal_name: StringName) -> CharacterAttackDefinition:
	return _character_attack_definitions_dictionary.get(character_attack_definition_internal_name, null)
