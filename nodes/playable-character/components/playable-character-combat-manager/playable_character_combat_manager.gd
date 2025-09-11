class_name PlayableCharacterCombatManager
extends Node

const IS_STAYING: String = "is_staying"
const IS_TARGETING: String = "is_targeting"
const TRACKED_TARGET_POSITION: String = "tracked_target_position"

const PLACEHOLDER_POSITION_DISTANCE: float = 20.0

@onready var _camera_behaviour_tree: BeehaveTree = %CameraBehaviourTree
@onready var _camera_behaviour_tree_blackboard: BHBlackboard = %CameraBehaviourTreeBlackboard
@onready var _gameplay_blackboard: BTBlackboard = _gameplay_finite_state_machine.blackboard
@onready var _animation_blackboard: BTBlackboard = _animation_finite_state_machine.blackboard

var playable_character: PlayableCharacter

var _tracked_target: TrackableTarget

@export var camera: PlayableCharacterCamera
@export var target_range: PlayableCharacterRange
@export var _gameplay_finite_state_machine: FiniteStateMachine
@export var _animation_finite_state_machine: FiniteStateMachine

func initialize(playable_character: PlayableCharacter) -> void:
	self.playable_character = playable_character
	
	_camera_behaviour_tree.enable()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_handle_targeting()

func _unhandled_input(event: InputEvent) -> void:
	_camera_behaviour_tree_blackboard.set_value(IS_STAYING, _handle_toggle_staying(_camera_behaviour_tree_blackboard.get_value("is_staying", false)))
	_gameplay_blackboard.set_value(IS_TARGETING, _handle_toggle_targeting(_gameplay_blackboard.get_value("is_targeting")))
	_animation_blackboard.set_value(IS_TARGETING, _handle_toggle_targeting(_animation_blackboard.get_value("is_targeting")))

func _handle_toggle_staying(is_staying: bool) -> bool:
	if Input.is_action_just_pressed("stay_camera"):
		return not is_staying
	return is_staying
func _handle_toggle_targeting(is_targeting: bool) -> bool:
	if Input.is_action_just_pressed("target") and Input.is_action_pressed("backwards"):
		if _tracked_target:
			_tracked_target.set_tracked(false)
			_tracked_target = null
		return false
	
	if Input.is_action_just_pressed("target"):
		return true
	
	return is_targeting

func _handle_targeting():
	if not _gameplay_blackboard.get_value(IS_TARGETING):
		_camera_behaviour_tree_blackboard.erase_value(TRACKED_TARGET_POSITION)
		_gameplay_blackboard.remove_value(TRACKED_TARGET_POSITION)
		_animation_blackboard.remove_value(TRACKED_TARGET_POSITION)
		return
	
	if target_range.targets_in_range.is_empty():
		var placeholder_position = (camera.get_front_direction() * PLACEHOLDER_POSITION_DISTANCE) + playable_character.global_position		
		_camera_behaviour_tree_blackboard.set_value(TRACKED_TARGET_POSITION, placeholder_position)
		_gameplay_blackboard.set_value(TRACKED_TARGET_POSITION, placeholder_position)
		_animation_blackboard.set_value(TRACKED_TARGET_POSITION, placeholder_position)
		return
	
	# if tracked target is null find the closest target
	if _tracked_target == null:
		var closest = _find_closest_target_in_target_range()
		_tracked_target = closest
		_tracked_target.set_tracked(true)
	
	if Input.is_action_just_pressed("track_next_target"):
		_tracked_target.set_tracked(false)
		var next_target = _find_next_target_in_target_range(_tracked_target)
		_tracked_target = next_target
		_tracked_target.set_tracked(true)
	
	if Input.is_action_just_pressed("track_previous_target"):
		_tracked_target.set_tracked(false)
		var next_target = _find_previous_target_in_target_range(_tracked_target)
		_tracked_target = next_target
		_tracked_target.set_tracked(true)
	
	_camera_behaviour_tree_blackboard.set_value(TRACKED_TARGET_POSITION, _tracked_target.global_position)
	_gameplay_blackboard.set_value(TRACKED_TARGET_POSITION, _tracked_target.global_position)
	_animation_blackboard.set_value(TRACKED_TARGET_POSITION, _tracked_target.global_position)

func _find_closest_target_in_target_range() -> TrackableTarget:
	var min_distance = 9999999
	var closest
	
	for target in target_range.targets_in_range:
		var distance = target_range.global_position.distance_to(target.global_position)
		if distance >= min_distance:
			continue
		
		min_distance = distance
		closest = target
	
	return closest

func _find_next_target_in_target_range(current_target: Node) -> TrackableTarget:
	assert(target_range.targets_in_range.has(current_target), "Could not find target {current_target} in TargetRange!".format({"current_target" : current_target.get_parent().name}))
	
	var current_index = target_range.targets_in_range.find(current_target)
	var next_index = current_index + 1
	if next_index >= target_range.targets_in_range.size():
		next_index = 0
	
	return target_range.targets_in_range[next_index]

func _find_previous_target_in_target_range(current_target: Node) -> TrackableTarget:
	assert(target_range.targets_in_range.has(current_target), "Could not find target {current_target} in TargetRange!".format({"current_target" : current_target.get_parent().name}))
	
	var current_index = target_range.targets_in_range.find(current_target)
	var next_index = current_index - 1
	if next_index < 0:
		next_index = target_range.targets_in_range.size() - 1
	
	return target_range.targets_in_range[next_index]

func _on_playable_character_target_range_target_entered(target: TrackableTarget) -> void:
	pass

func _on_playable_character_target_range_target_exited(target: TrackableTarget) -> void:
	if target == _tracked_target:
		_tracked_target.set_tracked(false)
		_tracked_target = null
