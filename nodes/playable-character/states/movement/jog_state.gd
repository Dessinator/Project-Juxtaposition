@tool
extends PlayableCharacterGameplayState

const AGILITY: StringName = &"agility"
const MOVEMENT_SPEED: StringName = &"movement_speed"

@export var _acceleration: float = 15.0
@export var _speed_multiplier: float = 2.0

@onready var _stamina_regeneration_delay_timer: Timer = %StaminaRegenerationDelayTimer

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	
	_handle_stamina_regeneration_delay(blackboard)

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var horizontal_camera_rotation = _camera.get_horizontal_rotation()
	var direction = _handle_direction_input(horizontal_camera_rotation)
	
	var stats = _character.get_character_stats()
	var agility_stat = stats.get_stat(AGILITY)
	var agility_value = agility_stat.get_value(false)
	var movement_speed_stat = stats.get_substat(MOVEMENT_SPEED)
	var movement_speed_value = movement_speed_stat.sample(agility_value, false)
	var speed = movement_speed_value * _speed_multiplier
	
	var velocity = _handle_jogging(actor.velocity, direction, speed, delta)
	
	actor.velocity = velocity
	if not velocity.is_zero_approx():
		var velocity_normalized = velocity.normalized()
		_playable_character_character_container.rotation.y = atan2(velocity_normalized.x, velocity_normalized.z)
	
	_handle_targeting(blackboard.get_value("is_targeting"))

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass

func _handle_direction_input(horizontal_rotation: float) -> Vector3:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = Vector3(input_direction.x, 0, input_direction.y)
	direction = direction.rotated(Vector3.UP, horizontal_rotation).normalized()
	
	return direction

func _handle_jogging(current_velocity: Vector3, direction: Vector3, speed: float, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(direction * speed, _acceleration * delta)
	return velocity

func _handle_targeting(is_targeting: bool):
	var character_animation_tree_expression_base = _character.get_node("%CharacterAnimationTreeExpressionBase")
	
	if not is_targeting:
		character_animation_tree_expression_base.travel_to_non_targeting_movement()
		return
	
	character_animation_tree_expression_base.travel_to_targeting_movement()
	var horizontal_camera_rotation = _camera.get_horizontal_rotation()
	_playable_character_character_container.rotation.y = horizontal_camera_rotation + PI

func _handle_stamina_regeneration_delay(blackboard: BTBlackboard):
	_stamina_regeneration_delay_timer.timeout.connect(_on_stamina_regeneration_delay_timer_timeout.bind(blackboard))
	if not blackboard.get_value("regenerate_stamina") and _stamina_regeneration_delay_timer.is_stopped():
		blackboard.set_value("regenerate_stamina", false)
		_stamina_regeneration_delay_timer.start()

func _on_stamina_regeneration_delay_timer_timeout(blackboard: BTBlackboard):
	blackboard.set_value("regenerate_stamina", true)
