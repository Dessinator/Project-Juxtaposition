class_name PlayableCharacterCharacterContainer
extends Node3D

signal current_character_changed(old: Character, new: Character)
signal character_switch_failed

enum CharacterSwitchType
{
	SWITCH_TYPE_INSTANT,
	SWITCH_TYPE_PARRY,
	SWITCH_TYPE_DODGE,
	SWITCH_TYPE_ATTACK,
	SWITCH_TYPE_JUXTAPOSITION
}

var _is_switching_character: bool = false
var _characters: Array[Character]
var _current_character: Character

@onready var _playable_character: PlayableCharacter = $".."

func _ready() -> void:
	_setup_characters()
	_handle_switch_to_character(0)

func _process(_delta: float) -> void:
	_handle_switching_input(_playable_character.can_switch_characters())

func get_current_character() -> Character:
	return _current_character
func get_characters() -> Array[Character]:
	return _characters

func _setup_characters():
	for child in get_children():
		_characters.append(child)
	
	for character in _characters:
		remove_child(character)

func _handle_switching_input(can_switch_characters: bool) -> bool:
	if not Input.is_action_just_pressed("switch_character"):
		return false
		
	if not can_switch_characters:
		character_switch_failed.emit()
		return false
	
	var switched = false
	
	if Input.is_action_just_pressed("character_1"):
		if _current_character == _characters[0]:
			#character_switch_failed.emit()
			return false
		switched = _handle_switch_to_character(0)
	elif Input.is_action_just_pressed("character_2"):
		if _current_character == _characters[1]:
			#character_switch_failed.emit()
			return false
		switched = _handle_switch_to_character(1)
	elif Input.is_action_just_pressed("character_3"):
		if _current_character == _characters[2]:
			#character_switch_failed.emit()
			return false
		switched = _handle_switch_to_character(2)
	
	return switched

func _handle_switch_to_character(index: int) -> bool:
	if _characters.size() < index + 1:
		character_switch_failed.emit()
		return false
	
	var old
	if not _current_character:
		old = null
	elif _current_character.get_parent() == self:
		old = _current_character
		remove_child(_current_character)
	_current_character = _characters[index]
	add_child(_current_character)
	current_character_changed.emit(old, _current_character)
	
	return true
