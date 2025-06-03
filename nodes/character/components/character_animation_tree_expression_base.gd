class_name CharacterAnimationTreeExpressionBase
extends Node

enum CharacterAnimationMovementLevel {
	LEVEL_WALK = 1,
	LEVEL_JOG = 2,
	LEVEL_SPRINT = 3,
}

@onready var _animation_tree: AnimationTree = %AnimationTree

var movement_vector: Vector2
var wallrun_vector: Vector2
var wallslide_position: float

func _process(delta: float) -> void:
	_update_movement_blend_position()
	_update_wallrunning_blend_position()
	_update_wallsliding_blend_position()

func _update_movement_blend_position():
	_animation_tree["parameters/Passive/NonTargetingMovement/blend_position"] = movement_vector.length()
	_animation_tree["parameters/Passive/TargetingMovement/blend_position"] = movement_vector

func _update_wallrunning_blend_position():
	_animation_tree["parameters/Passive/Wallrunning/blend_position"] = wallrun_vector

func _update_wallsliding_blend_position():
	_animation_tree["parameters/Passive/Wallsliding/blend_position"] = wallslide_position

func set_movement_vector(normalized_direction: Vector2, level: CharacterAnimationMovementLevel):
	movement_vector = normalized_direction * level

func set_wallrun_vector(normalized_direction: Vector2):
	wallrun_vector = normalized_direction

func set_wallslide_vector(direction: float):
	wallslide_position = direction

func travel_to_non_targeting_movement():
	var state_machine = _animation_tree["parameters/Passive/playback"]
	state_machine.travel("NonTargetingMovement")

func travel_to_targeting_movement():
	var state_machine = _animation_tree["parameters/Passive/playback"]
	state_machine.travel("TargetingMovement")

func travel_to_wallrunning():
	var state_machine = _animation_tree["parameters/Passive/playback"]
	state_machine.travel("Wallrunning")

func travel_to_wallsliding():
	var state_machine = _animation_tree["parameters/Passive/playback"]
	state_machine.travel("Wallsliding")

func travel_to_dodge():
	var state_machine = _animation_tree["parameters/Passive/playback"]
	state_machine.travel("dodge")

func travel_to_skid():
	var state_machine = _animation_tree["parameters/Passive/playback"]
	state_machine.travel("skid")

func travel_to_jump():
	var state_machine = _animation_tree["parameters/Passive/playback"]
	state_machine.travel("jump")

func travel_to_fall():
	var state_machine = _animation_tree["parameters/Passive/playback"]
	state_machine.travel("fall")

func travel_to_landing():
	var state_machine = _animation_tree["parameters/Passive/playback"]
	state_machine.travel("landing")

func travel_to_mantle():
	var state_machine = _animation_tree["parameters/Passive/playback"]
	state_machine.travel("mantle")
