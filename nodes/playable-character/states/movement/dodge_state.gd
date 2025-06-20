@tool
extends PlayableCharacterGameplayState

@export var _force: float = 10.0
@export var _skid_threshold: float = 0.5
@export var _stamina_drain: int = 3
@export var _dodge_time_timer: Timer

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
	
	actor.velocity = velocity
	
	var character_container = actor.get_playable_character_character_container()
	var character = character_container.get_current_character()
	var status = character.get_character_status()
	status.exhaust(_stamina_drain)
	
	_dodge_time_timer.timeout.connect(_on_dodge_time_timer_timeout.bind(actor, blackboard.get_value("auto_jog")))
	_dodge_time_timer.start()

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	_dodge_time_timer.timeout.disconnect(_on_dodge_time_timer_timeout)
	_dodge_time_timer.stop()

func get_stamina_drain() -> int:
	return _stamina_drain

func _handle_direction_input(horizontal_rotation: float) -> Vector3:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = Vector3(input_direction.x, 0, input_direction.y)
	direction = direction.rotated(Vector3.UP, horizontal_rotation).normalized()
	
	return direction

func _handle_dodge_force(direction: Vector3) -> Vector3:
	var velocity = direction * _force
	
	return velocity

func _handle_skidding(playable_character: PlayableCharacter, direction: Vector3) -> bool:
	if direction.is_zero_approx():
		get_parent().fire_event("on_start_skidding")
		return true
	
	var dot = playable_character.velocity.normalized().dot(direction)
	if dot <= -_skid_threshold:
		get_parent().fire_event("on_start_skidding")
		return true
	
	return false

func _on_dodge_time_timer_timeout(playable_character: PlayableCharacter, auto_jog: bool):
	if not playable_character.is_on_floor():
		get_parent().fire_event("on_start_falling")
		return
	
	var direction = _handle_direction_input(_camera.get_horizontal_rotation())
	var will_skid = _handle_skidding(playable_character, direction)
	if will_skid:
		return
	
	if Input.is_action_pressed("sprint"):
		get_parent().fire_event("on_start_sprinting")
		return
	
	if auto_jog:
		get_parent().fire_event("on_start_jogging")
		return
	
	get_parent().fire_event("on_start_walking")
