class_name CharacterAnimationTreeExpressionBase
extends Node

const GROUNDED_STATE_MACHINE: String = "parameters/grounded_state_machine"
const AIRBORNE_STATE_MACHINE: String = "parameters/airborne_state_machine"

const NON_TARGETING_MOVEMENT: String = "non_targeting_movement"
const TARGETING_MOVEMENT: String = "targeting_movement"
const WALLRUN_MOVEMENT: String = "wallrun_movement"
const WALLSLIDE_MOVEMENT: String = "wallslide_movement"
const SKID: String = "skid"
const JUMP: String = "jump"
const DODGE: String = "dodge"
const FALL: String = "fall"
const LAND: String = "land"
const MANTLE: String = "mantle"
const DIE: String = "die"
const CHARGED_LIGHT_ATTACK: String = "charged_light_attack"
const CHARGED_HEAVY_ATTACK: String = "charged_heavy_attack"

enum CharacterAnimationMovementLevel {
	LEVEL_WALK = 1,
	LEVEL_JOG = 2,
	LEVEL_SPRINT = 3,
}

@onready var _animation_tree: AnimationTree = %AnimationTree

var top_level_state_machine: String
var lateral_movement_vector: Vector2
var wall_movement_vector: Vector2

@export var grounded_light_attack_phase_count: int
@export var arial_light_attack_phase_count: int
@export var grounded_heavy_attack_phase_count: int
@export var arial_heavy_attack_phase_count: int

func _ready() -> void:
	travel_to_grounded()

func _process(delta: float) -> void:
	_update_movement_blend_positions()

func _update_movement_blend_positions():
	_animation_tree["parameters/grounded_state_machine/non_targeting_movement/blend_position"] = lateral_movement_vector
	_animation_tree["parameters/grounded_state_machine/targeting_movement/blend_position"] = lateral_movement_vector
	_animation_tree["parameters/grounded_state_machine/wallrun_movement/blend_position"] = wall_movement_vector
	_animation_tree["parameters/grounded_state_machine/wallslide_movement/blend_position"] = wall_movement_vector

func set_lateral_movement_vector(normalized_direction: Vector2, level: CharacterAnimationMovementLevel):
	lateral_movement_vector = normalized_direction * level
func set_wall_movement_vector(normalized_direction: Vector2):
	wall_movement_vector = normalized_direction

func travel_to_grounded():
	var state_machine = _animation_tree["parameters/playback"]
	state_machine.travel(GROUNDED_STATE_MACHINE)
	top_level_state_machine = GROUNDED_STATE_MACHINE
func travel_to_airborne():
	var state_machine = _animation_tree["parameters/playback"]
	state_machine.travel(AIRBORNE_STATE_MACHINE)
	top_level_state_machine = AIRBORNE_STATE_MACHINE

func travel_to_non_targeting_movement():
	var path = top_level_state_machine + "/playback"
	var state_machine = _animation_tree[path]
	state_machine.travel(NON_TARGETING_MOVEMENT)
func travel_to_targeting_movement():
	var path = top_level_state_machine + "/playback"
	var state_machine = _animation_tree[path]
	state_machine.travel(TARGETING_MOVEMENT)

func travel_to_wallrunning():
	var path = GROUNDED_STATE_MACHINE + "/playback"
	var state_machine = _animation_tree[path]
	state_machine.travel(WALLRUN_MOVEMENT)
func travel_to_wallsliding():
	var path = GROUNDED_STATE_MACHINE + "/playback"
	var state_machine = _animation_tree[path]
	state_machine.travel(WALLSLIDE_MOVEMENT)
func travel_to_skid():
	var path = GROUNDED_STATE_MACHINE + "/playback"
	var state_machine = _animation_tree[path]
	state_machine.travel(SKID)
func travel_to_jump():
	var path = GROUNDED_STATE_MACHINE + "/playback"
	var state_machine = _animation_tree[path]
	state_machine.travel(JUMP)

func travel_to_dodge():
	var path = top_level_state_machine + "/playback"
	var state_machine = _animation_tree[path]
	state_machine.travel(DODGE)
func travel_to_fall():
	var path = top_level_state_machine + "/playback"
	var state_machine = _animation_tree[path]
	state_machine.travel(FALL)
func travel_to_land():
	var path = top_level_state_machine + "/playback"
	var state_machine = _animation_tree[path]
	state_machine.travel(LAND)
func travel_to_mantle():
	var path = top_level_state_machine + "/playback"
	var state_machine = _animation_tree[path]
	state_machine.travel(MANTLE)
func travel_to_death():
	var path = top_level_state_machine + "/playback"
	var state_machine = _animation_tree[path]
	state_machine.travel(DIE)

func travel_to_light_attack(phase: int):
	if phase > grounded_light_attack_phase_count:
		return
	elif phase <= 0:
		return
	
	var path = top_level_state_machine + "/playback"
	var state_machine = _animation_tree[path]
	var animation_name = "light_attack_" + str(phase)
	state_machine.travel(animation_name)
func travel_to_heavy_attack(phase: int):
	if phase > grounded_heavy_attack_phase_count:
		return
	elif phase <= 0:
		return
	
	var path = top_level_state_machine + "/playback"
	var state_machine = _animation_tree[path]
	var animation_name = "heavy_attack_" + str(phase)
	state_machine.travel(animation_name)

func travel_to(animation_name: String):
	var path = top_level_state_machine + "/playback"
	var state_machine = _animation_tree[path]
	state_machine.travel(animation_name)
