class_name NonplayableCharacterCharacterContainer
extends Node3D

signal character_added(character: Character)
signal character_removed(character: Character)
signal characters_cleared()

signal current_character_changed(old: Character, new: Character)
signal character_switch_failed

@onready var _nonplayable_character: NonplayableCharacter = $".."

var _is_switching_character: bool = false
var _characters: Dictionary[StringName, Character]
var _current_character: Character

@export var _max_character_count: int = 3

func _ready() -> void:
	_setup_characters()
	handle_switch_to_character(0)

func clear_characters():
	for character in _characters.values():
		character.queue_free()
	
	_characters = {}
	characters_cleared.emit()

func add_character(character: Character):
	if _characters.keys().size() + 1 > _max_character_count:
		return
	
	var internal_name = character.get_character_data().internal_name
	_characters[internal_name] = character
	if _characters.keys().size() == 1:
		handle_switch_to_character(0)
	character_added.emit(character)

func add_character_packet(character_packet: CharacterPacket):
	var internal_name = character_packet.character_data.internal_name 
	
	if _characters.has(internal_name):
		return
	
	var character = character_packet.character_scene.instantiate()
	_characters[internal_name] = character
	if _characters.keys().size() == 1:
		handle_switch_to_character(0)
	character_added.emit(character)

## this method does NOT free the character node.
func remove_character(character_internal_name: StringName):
	assert(_characters.has(character_internal_name), "NonplayableCharacterCharacterContainer: Could not find character by internal_name " + str(character_internal_name))
	
	var character = _characters[character_internal_name]
	_characters.erase(character_internal_name)
	character_removed.emit(character)

func get_current_character() -> Character:
	return _current_character
func get_characters() -> Dictionary[StringName, Character]:
	return _characters
func get_next_alive_character_index() -> int:
	if all_characters_dead():
		return -1
	
	var next_character_index = -1
	
	var index = _characters.values().find(_current_character)
	while next_character_index == -1:
		index += 1
		if index >= _characters.size():
			index = 0
		var next = _characters.values()[index]
		if next.get_character_status().is_dead():
			continue
		next_character_index = index
	
	return next_character_index

func all_characters_dead() -> bool:
	for character in _characters.values():
		if not character.get_character_status().is_dead():
			return false
	
	return true

func _setup_characters():
	for child in get_children():
		if not child is Character:
			continue
		add_character(child)
	
	for character in _characters.values():
		remove_child(character)

func handle_switch_to_character(index: int) -> bool:
	if _characters.size() < index + 1:
		character_switch_failed.emit()
		return false
	
	if _characters.values()[index].is_initialized():
		if _characters.values()[index].get_character_status().is_dead():
			character_switch_failed.emit()
			return false
	
	var old
	if not _current_character:
		old = null
	elif _current_character.get_parent() == self:
		old = _current_character
		remove_child(_current_character)
	_current_character = _characters.values()[index]
	add_child(_current_character)
	current_character_changed.emit(old, _current_character)
	
	return true
