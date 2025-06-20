@tool
extends PlayableCharacterGameplayState

const AGILITY: StringName = &"agility"
const MOVEMENT_SPEED: StringName = &"movement_speed"

@export var _force: float = 10.0
@export var _vertical_force: float = 5.0
@export var _gravity: float = 9.8
@export var _acceleration: float = 40.0

func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	var mantle_ray_cast = _character.get_mantle_ray_cast()
	
	if not mantle_ray_cast.is_colliding():
		return
	
	var collision_point = mantle_ray_cast.get_collision_point()
	var target_position = Vector3(
		actor.position.x,
		collision_point.y,
		actor.position.z
	)
	actor.position = target_position
	
	var horizontal_camera_rotation = _camera.get_horizontal_rotation()
	var direction = _handle_direction_input(horizontal_camera_rotation)
	if direction.is_zero_approx():
		direction = Vector3.FORWARD.rotated(Vector3.UP, _playable_character_character_container.rotation.y + PI)
	
	var stats = _character.get_character_stats()
	var agility_stat = stats.get_stat(AGILITY)
	var agility_value = agility_stat.get_value(false)
	var movement_speed_stat = stats.get_substat(MOVEMENT_SPEED)
	var movement_speed_value = movement_speed_stat.sample(agility_value, false)
	var speed = movement_speed_value * _force
	
	var velocity = _handle_mantle_force(direction, speed)
	
	actor.velocity = velocity
	
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	if not horizontal_velocity.is_zero_approx():
		var horizontal_velocity_normalized = horizontal_velocity.normalized()
		_playable_character_character_container.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)

func _on_update(delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var horizontal_camera_rotation = _camera.get_horizontal_rotation()
	var direction = _handle_direction_input(horizontal_camera_rotation)
	
	var stats = _character.get_character_stats()
	var agility_stat = stats.get_stat(AGILITY)
	var agility_value = agility_stat.get_value(false)
	var movement_speed_stat = stats.get_substat(MOVEMENT_SPEED)
	var movement_speed_value = movement_speed_stat.sample(agility_value, false)
	
	var velocity = _handle_mantling(actor.velocity, direction, movement_speed_value, delta)
	if velocity.y < 0:
		get_parent().fire_event("on_start_falling")
		return
	
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	actor.velocity = velocity
	if not horizontal_velocity.is_zero_approx():
		var horizontal_velocity_normalized = horizontal_velocity.normalized()
		_playable_character_character_container.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)

func _handle_mantle_force(normalized_direction: Vector3, speed: float) -> Vector3:
	var velocity = Vector3(
		normalized_direction.x * speed,
		_vertical_force,
		normalized_direction.z * speed
	)
	
	return velocity

func _handle_mantling(current_velocity: Vector3, direction: Vector3, speed: float, delta: float) -> Vector3:
	var velocity = Vector3.ZERO
	if direction.is_zero_approx():
		velocity = current_velocity.move_toward((current_velocity.normalized() * speed) + (Vector3.DOWN * _gravity), _acceleration * delta)
	else:
		velocity = current_velocity.move_toward((direction * speed) + (Vector3.DOWN * _gravity), _acceleration * delta)
	
	return velocity

func _handle_direction_input(horizontal_rotation: float) -> Vector3:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = Vector3(input_direction.x, 0, input_direction.y)
	direction = direction.rotated(Vector3.UP, horizontal_rotation).normalized()
	
	return direction
