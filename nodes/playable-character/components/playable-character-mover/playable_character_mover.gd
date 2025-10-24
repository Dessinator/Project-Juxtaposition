class_name PlayableCharacterMover
extends Node

var _playable_character: PlayableCharacter
var _playable_character_character_container: PlayableCharacterCharacterContainer

var _animation_tree: AnimationTree
var _animation_player: AnimationPlayer
var _animation_state

var can_move: bool

var direction: Vector3
var vertical_velocity: Vector3
var turn_speed: float = 10
var root_velocity: Vector3 
var root_rotation: Quaternion

@export var use_root_motion: bool = true
@export var use_root_rotation: bool = true

func initialize(playable_character: PlayableCharacter):
	_playable_character = playable_character
	_playable_character_character_container = playable_character.get_playable_character_character_container()
	var current_character = _playable_character_character_container.get_current_character()

	_animation_tree = current_character.animation_tree
	_animation_player = current_character.get_character_model_animation_player()
	_animation_state = _animation_tree.get("parameters/playback")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	root_velocity = _calculate_root_motion(delta)
	root_rotation = _calculate_root_rotation()
	_playable_character_character_container.quaternion *= root_rotation

func _physics_process(delta: float) -> void:
	_animation_tree.set("parameters/conditions/start_move", can_move)
	_animation_tree.set("parameters/conditions/idle", !can_move)

	if direction.is_zero_approx():
		can_move = false
	else:
		can_move = true
	
	var rotation = _playable_character_character_container.rotation.y
	if not direction.is_zero_approx():
		rotation = lerp_angle(_playable_character_character_container.rotation.y, atan2(direction.x, direction.z), turn_speed * delta)
	_playable_character_character_container.rotation.y = rotation

	if use_root_motion:
		_playable_character.velocity = root_velocity
	
	_playable_character.move_and_slide()

func set_velocity(velocity: Vector3):
	_playable_character.velocity = velocity

func _on_playable_character_character_container_current_character_changed(_old: Character, new: Character) -> void:
	_animation_tree = new.animation_tree
	_animation_player = new.get_character_model_animation_player()
	_animation_state = _animation_tree.get("parameters/playback")

func _calculate_root_motion(delta: float) -> Vector3:
	if not use_root_motion:
		return Vector3.ZERO

	var root_position = _animation_tree.get_root_motion_position()
	var current_rotation = _animation_tree.get_root_motion_rotation_accumulator().inverse() * _playable_character_character_container.quaternion
	var motion = current_rotation * root_position / delta

	return motion
func _calculate_root_rotation() -> Quaternion:
	if not use_root_rotation:
		return Quaternion.IDENTITY

	return _animation_tree.get_root_motion_rotation()
