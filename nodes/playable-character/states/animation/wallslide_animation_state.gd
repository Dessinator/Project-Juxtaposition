@tool
extends PlayableCharacterAnimationState

var _wallslide_position: float

@onready var _camera: PlayableCharacterCamera = %PlayableCharacterCamera
@onready var _gameplay_finite_state_machine: FiniteStateMachine = %GameplayFiniteStateMachine

# Executes after the state is entered.
func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	_update_character_animation_tree_expression_base()

# Executes every _process call, if the state is active.
func _on_update(_delta: float, actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	_wallslide_position = _handle_wallslide_position()
	
	_update_character_animation_tree_expression_base()

func _handle_direction_input() -> Vector2:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = input_direction.normalized()
	
	return direction

func _handle_wallslide_position() -> float:
	var cam_basis = _camera.get_camera().global_transform.basis
	var input_vector = _handle_direction_input()
	var move_dir = (cam_basis.x * input_vector.x) + (cam_basis.z * input_vector.y)
	move_dir = move_dir.normalized()

	var wall_normal = _gameplay_finite_state_machine.blackboard.get_value("current_wall_normal")
	var wall_move_dir = move_dir - wall_normal * move_dir.dot(wall_normal)
	wall_move_dir = wall_move_dir.normalized()

	var world_up = Vector3.UP
	var wall_right = wall_normal.cross(world_up).normalized()
	var lateral_amount = -wall_move_dir.dot(wall_right)
	
	var wallslide_position = lateral_amount
	
	return wallslide_position

func _update_character_animation_tree_expression_base():
	_character_animation_tree_expression_base.travel_to_wallsliding()
	_character_animation_tree_expression_base.set_wallslide_vector(_wallslide_position)
