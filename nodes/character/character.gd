class_name Character
extends Node3D

# Responsible for essentially defining a character, their attacks, their model, animations, etc.
# Should be the child of a PlayableCharacter node.

@export var _character_metadata: CharacterMetadata

@export var _character_model: Node3D
@export var _character_stats: CharacterStats
@export var _character_switcher_visual_packedscene: PackedScene
@export var _character_status_visual_packedscene: PackedScene
@export var _character_attack_state_machine: PackedScene
@export var _mantle_ray_cast: RayCast3D

var _character_status: CharacterStatus
var _character_model_animation_player: AnimationPlayer
var _character_model_animation_names: Array[StringName]
var _character_model_hitbox_animation_player: AnimationPlayer
var _character_model_hitbox_animation_names: Array[StringName]

@onready var _character_attack_definition_manager: CharacterAttackDefinitionManager = %CharacterAttackDefinitionManager

func _ready() -> void:
	_initialize_character_stats()
	_initialize_character_status()
	
	var data = _grab_model_data(_character_model)
	_character_model_animation_player = data["animation_player"]
	_character_model_animation_names = data["animation_names"]
	_character_model_hitbox_animation_player = data["hitbox_animation_player"]
	_character_model_hitbox_animation_names = data["hitbox_animation_names"]

func get_character_metadata() -> CharacterMetadata:
	return _character_metadata

func get_character_model_animation_player() -> AnimationPlayer:
	return _character_model_animation_player
func get_character_model_animation_names() -> Array[StringName]:
	return _character_model_animation_names
func get_character_model_hitbox_animation_player() -> AnimationPlayer:
	return _character_model_hitbox_animation_player
func get_character_model_hitbox_animation_names() -> Array[StringName]:
	return _character_model_hitbox_animation_names

func get_character_switcher_visual_packedscene() -> PackedScene:
	return _character_switcher_visual_packedscene
func get_character_status_visual_packedscene() -> PackedScene:
	return _character_status_visual_packedscene
func get_character_attack_definition_manager() -> CharacterAttackDefinitionManager:
	return _character_attack_definition_manager
func get_character_attack_state_machine() -> PackedScene:
	return _character_attack_state_machine

func get_character_stats() -> CharacterStats:
	return _character_stats
func get_character_status() -> CharacterStatus:
	return _character_status

func get_mantle_ray_cast() -> RayCast3D:
	return _mantle_ray_cast

func _initialize_character_stats():
	_character_stats.initialize()
func _initialize_character_status():
	_character_status = CharacterStatus.new()
	_character_status.died.connect(_on_died)
	_character_status.initialize(self, _character_stats)

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
	var animations: Array[StringName] = []
	if animation_library:
		animations = animation_library.get_animation_list()
	
	return animations

func _on_died():
	pass
