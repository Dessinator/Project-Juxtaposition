class_name CharacterMetadata
extends Resource

@export var _name: String
@export var _nickname: String
@export var _pronouns: String
@export_multiline var _lore: String

func get_character_name() -> String:
	return _name
func get_character_nickname() -> String:
	return _nickname
func get_character_pronouns() -> String:
	return _pronouns
func get_character_lore() -> String:
	return _lore
