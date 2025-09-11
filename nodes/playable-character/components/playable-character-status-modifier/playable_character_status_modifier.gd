class_name PlayableCharacterStatusModifier
extends Node

@onready var _playable_character_character_container: PlayableCharacterCharacterContainer = %PlayableCharacterCharacterContainer

var _current_character_status: CharacterStatus

@export var _damage_amount: int
@export var _heal_amount: int

func initialize():
	_playable_character_character_container.current_character_changed.connect(_on_current_character_changed)
	
	var current_character = _playable_character_character_container.get_current_character()
	_current_character_status = current_character.get_character_status()

func _on_current_character_changed(_old, _new):
	_current_character_status = _new.get_character_status()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_damage_player"):
		_damage(_current_character_status)
	if event.is_action_pressed("debug_crit_damage_player"):
		_damage_crit(_current_character_status)
	if event.is_action_pressed("debug_heal_player"):
		_heal(_current_character_status)

func _damage(status: CharacterStatus):
	status.damage(_damage_amount, false, 0, true)

func _damage_crit(status: CharacterStatus):
	status.damage(_damage_amount, true, 0, true)

func _heal(status: CharacterStatus):
	status.heal(_heal_amount, true)
	
