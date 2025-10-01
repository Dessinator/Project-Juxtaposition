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
@onready var _juxtapometer_decay_timer: Timer = $JuxtapometerDecayTimer

func _ready() -> void:
	_setup_characters()
	handle_switch_to_character(0)

func _process(_delta: float) -> void:
	_handle_switching_input(_playable_character.can_switch_characters())

func get_current_character() -> Character:
	return _current_character
func get_characters() -> Array[Character]:
	return _characters
func get_next_alive_character_index() -> int:
	if all_characters_dead():
		return -1
	
	var next_character_index = -1
	
	var index = _characters.find(_current_character)
	while next_character_index == -1:
		index += 1
		if index >= _characters.size():
			index = 0
		var next = _characters[index]
		if next.get_character_status().is_dead():
			continue
		next_character_index = index
	
	return next_character_index

func all_characters_dead() -> bool:
	for character in _characters:
		if not character.get_character_status().is_dead():
			return false
	
	return true

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
		switched = handle_switch_to_character(0)
	elif Input.is_action_just_pressed("character_2"):
		if _current_character == _characters[1]:
			#character_switch_failed.emit()
			return false
		switched = handle_switch_to_character(1)
	elif Input.is_action_just_pressed("character_3"):
		if _current_character == _characters[2]:
			#character_switch_failed.emit()
			return false
		switched = handle_switch_to_character(2)
	
	return switched
func handle_switch_to_character(index: int) -> bool:
	if _characters.size() < index + 1:
		character_switch_failed.emit()
		return false
	
	if _characters[index].get_character_status().is_dead():
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

func _on_juxtapometer_decay_timer_timeout() -> void:
	_handle_juxtometer_depletion()
func _handle_juxtometer_depletion():
	for character in _characters:
		var status = character.get_character_status()
		if not status.is_juxtaposed():
			continue
		
		status.deplete_juxtometer(5)
