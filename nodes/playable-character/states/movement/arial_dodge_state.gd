@tool
extends PlayableCharacterGameplayState

@onready var _airborne_timer: Timer = %AirborneTimer
@onready var _dodge_time_timer: Timer = %DodgeTimeTimer

@export var _gravity: float
@export var _acceleration: int = 40
@export var _force: float = 10.0

@export var _slow_motion: float
@export var _slow_motion_fade_time: float = 1

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	var horizontal_camera_rotation = _camera.get_horizontal_rotation()
	var direction = _handle_direction_input(horizontal_camera_rotation)
	if direction.is_zero_approx():
		direction = Vector3.FORWARD.rotated(Vector3.UP, horizontal_camera_rotation)
	var velocity = _handle_dodge_force(direction)
	
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	actor.velocity = velocity
	if not horizontal_velocity.is_zero_approx():
		var horizontal_velocity_normalized = horizontal_velocity.normalized()
		_playable_character_character_container.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)
	
	var character_container = actor.get_playable_character_character_container()
	var character = character_container.get_current_character()
	var status = character.get_character_status()
	status.set_immune(true)
	
	_set_slow_motion(_slow_motion)
	var tween = get_tree().create_tween()
	tween.tween_method(_set_slow_motion, _slow_motion, 1.0, _slow_motion_fade_time)
	
	_handle_starting_airborne_timer()
	_dodge_time_timer.timeout.connect(_on_dodge_time_timer_timeout)
	_dodge_time_timer.start()

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var velocity = _handle_falling(actor.velocity, delta)
	actor.velocity = velocity

# Executes before the state is exited.
func _on_exit(_actor: Node, blackboard: BTBlackboard) -> void:
	blackboard.set_value("interrupted_damage_instance", null)
	_dodge_time_timer.timeout.disconnect(_on_dodge_time_timer_timeout)

func _handle_direction_input(horizontal_rotation: float) -> Vector3:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = Vector3(input_direction.x, 0, input_direction.y)
	direction = direction.rotated(Vector3.UP, horizontal_rotation).normalized()
	
	return direction

func _handle_dodge_force(direction: Vector3) -> Vector3:
	var velocity = Vector3(
		direction.x * _force,
		_force,
		direction.z * _force
	)
	
	return velocity

func _handle_falling(current_velocity: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(Vector3.DOWN * _gravity, _acceleration * delta)
	return velocity

func _on_dodge_time_timer_timeout():
	_handle_transitions()

func _handle_transitions():
	if _airborne_timer.is_stopped():
		get_parent().fire_event(ON_START_FALLING)
		return
	get_parent().fire_event(ON_START_AIRBORNE)

func _handle_starting_airborne_timer():
	if not _airborne_timer.is_stopped():
		var new_time = _airborne_timer.time_left + 1.5
		if new_time > _airborne_timer.wait_time:
			new_time = _airborne_timer.wait_time
		_airborne_timer.start(new_time)
		return
	_airborne_timer.start()

func _set_slow_motion(slow_motion: float):
	Engine.time_scale = slow_motion
