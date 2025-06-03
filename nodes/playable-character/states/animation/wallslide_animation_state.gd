@tool
extends FSMState

@export var _character: Character
@export var _camera: PlayableCharacterCamera

@onready var _gameplay_finite_state_machine: FiniteStateMachine = %GameplayFiniteStateMachine
@onready var _character_animation_tree_expression_base: CharacterAnimationTreeExpressionBase = _character.get_node("%CharacterAnimationTreeExpressionBase")

# Executes after the state is entered.
func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	_character_animation_tree_expression_base.travel_to_wallsliding()

# Executes every _process call, if the state is active.
func _on_update(_delta: float, actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var cam_basis = _camera.get_camera().global_transform.basis
	var input_vector = _handle_direction_input()
	var move_dir = (cam_basis.x * input_vector.x) + (cam_basis.z * input_vector.y)
	move_dir = move_dir.normalized()

	var wall_normal = _gameplay_finite_state_machine.blackboard.get_value("current_wall_normal")
	var wall_move_dir = move_dir - wall_normal * move_dir.dot(wall_normal)
	wall_move_dir = wall_move_dir.normalized()

	var world_up = Vector3.UP
	#var vertical_amount = wall_move_dir.dot(world_up)
	var wall_right = wall_normal.cross(world_up).normalized()
	var lateral_amount = -wall_move_dir.dot(wall_right)
	
	var wallslide_position = lateral_amount
	
	print(wallslide_position)
	
	_character_animation_tree_expression_base.set_wallslide_vector(wallslide_position)

func _handle_direction_input() -> Vector2:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = input_direction.normalized()
	
	return direction
