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

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_damage_player"):
		_damage(_current_character_status)
	if event.is_action_pressed("debug_crit_damage_player"):
		_damage_crit(_current_character_status)
	if event.is_action_pressed("debug_heal_player"):
		_heal(_current_character_status)

func _damage(status: CharacterStatus):
	var damage_instance = DamageInstance.new()
	damage_instance.source = self
	damage_instance.base_damage = _damage_amount
	damage_instance.is_crit = false
	damage_instance.spawn_damage_number = true
	status.damage(damage_instance)

func _damage_crit(status: CharacterStatus):
	var damage_instance = DamageInstance.new()
	damage_instance.source = self
	damage_instance.base_damage = _damage_amount
	damage_instance.is_crit = true
	damage_instance.spawn_damage_number = true
	status.damage(damage_instance)

func _heal(status: CharacterStatus):
	var heal_instance = HealInstance.new()
	heal_instance.source = self
	heal_instance.heal = _heal_amount
	heal_instance.spawn_heal_number = true
	status.heal(heal_instance)
	
