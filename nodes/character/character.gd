class_name Character
extends Node3D

# Responsible for essentially defining a character, their attacks, their model, animations, etc.
# Should be the child of a PlayableCharacter node.

@export var _character_model: Node3D
@export var _character_stats: CharacterStats
@export var _character_attack_state_machine: PackedScene

var _character_model_animation_player: AnimationPlayer
var _character_model_hitbox_animation_player: AnimationPlayer

var _character_model_animation_names: Array[StringName]
var _character_model_hitbox_animation_names: Array[StringName]

@onready var _character_attack_definition_manager: CharacterAttackDefinitionManager = %CharacterAttackDefinitionManager

func _ready() -> void:
	_character_stats.initialize()
	
	var data = _grab_model_data(_character_model)
	_character_model_animation_player = data["animation_player"]
	_character_model_animation_names = data["animation_names"]
	_character_model_hitbox_animation_player = data["hitbox_animation_player"]
	_character_model_hitbox_animation_names = data["hitbox_animation_names"]

func get_character_model_animation_player() -> AnimationPlayer:
	return _character_model_animation_player
func get_character_model_animation_names() -> Array[StringName]:
	return _character_model_animation_names
func get_character_model_hitbox_animation_player() -> AnimationPlayer:
	return _character_model_hitbox_animation_player
func get_character_model_hitbox_animation_names() -> Array[StringName]:
	return _character_model_hitbox_animation_names

func get_character_attack_definition_manager() -> CharacterAttackDefinitionManager:
	return _character_attack_definition_manager
func get_character_attack_state_machine() -> PackedScene:
	return _character_attack_state_machine

func get_character_stats() -> CharacterStats:
	return _character_stats

func _grab_model_data(model: Node3D):
	var data = {}
	var names_array
	var hitbox_names_array
	if not model:
		names_array = []
		hitbox_names_array = []
	
	var animation_player = model.get_node("%AnimationPlayer")
	var hitbox_animation_player = model.get_node("%HitboxAnimationPlayer")
	names_array = _grab_animation_names(animation_player)
	hitbox_names_array = _grab_animation_names(hitbox_animation_player)
	
	data["animation_player"] = animation_player
	data["animation_names"] = names_array
	data["hitbox_animation_player"] = hitbox_animation_player
	data["hitbox_animation_names"] = hitbox_names_array
	
	return data

func _grab_animation_names(animation_player: AnimationPlayer):
	var animation_library = animation_player.get_animation_library("")
	var animations = animation_library.get_animation_list()
	
	return animations
