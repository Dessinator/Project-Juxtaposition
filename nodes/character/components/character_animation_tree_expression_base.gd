class_name CharacterAnimationTreeExpressionBase
extends Node

enum CharacterAnimationMovementLevel {
	LEVEL_WALK = 1,
	LEVEL_JOG = 2,
	LEVEL_SPRINT = 3,
}

@onready var _animation_tree: AnimationTree = %AnimationTree

var movement_vector: Vector2

func _process(delta: float) -> void:
	_update_movement_blend_position()

func _update_movement_blend_position():
	_animation_tree["parameters/Passive/Movement/blend_position"] = movement_vector

func set_movement_vector(normalized_direction: Vector2, level: CharacterAnimationMovementLevel):
	movement_vector = normalized_direction * level

func travel_to_movement():
	var state_machine = _animation_tree["parameters/Passive/playback"]
	state_machine.travel("Movement")

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
