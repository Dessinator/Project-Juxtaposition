@tool
extends FSMState

const AGILITY: StringName = &"agility"
const MOVEMENT_SPEED: StringName = &"movement_speed"

@export var _acceleration: float
@export var _speed_multiplier: float
@export var _skid_threshold: float
@export var _stamina_drain: int

@export var _camera: PlayableCharacterCamera
@export var _character: Character

@export var _drain_stamina_timer: Timer
@export var _allow_skidding_delay_timer: Timer
@export var _skid_cooldown_timer: Timer

@onready var _character_visual: Node3D = %CharacterVisual

@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine
@onready var _sprint_animation_state: Node = %SprintAnimationState

@onready var _stamina_regeneration_delay_timer: Timer = %StaminaRegenerationDelayTimer
@onready var _playable_character_sprinting_particles: Node3D = %PlayableCharacterSprintingParticles

func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	var status = actor.get_status()
	
	var particle_system = _playable_character_sprinting_particles.get_node("%GPUParticles3D")
	particle_system.emitting = true
	
	_stamina_regeneration_delay_timer.stop()
	blackboard.set_value("regenerate_stamina", false)
	
	status.stamina_modified.connect(_on_status_stamina_modified.bind(status, blackboard))
	
	_drain_stamina_timer.timeout.connect(_on_drain_stamina_timer_timeout.bind(status))
	if _drain_stamina_timer.paused:
		_drain_stamina_timer.paused = false
	else:
		_drain_stamina_timer.start()
	
	if get_parent().last_active_state == %IdleState or get_parent().last_active_state == %WalkState:
		blackboard.set_value("is_skidding_allowed_while_running", false)
	
	_animation_finite_state_machine.change_state(_sprint_animation_state)
	if blackboard.get_value("is_skidding_allowed_while_running"):
		pass
		#_running_dust_trail.emitting = true
	else:
		if blackboard.get_value("is_skidding_allowed_while_running") == null:
			blackboard.set_value("is_skidding_allowed_while_running", false)
		
		_allow_skidding_delay_timer.timeout.connect(_on_allow_skidding_delay_timer_timeout.bind(blackboard))
		if _allow_skidding_delay_timer.paused:
			_allow_skidding_delay_timer.paused = false
			return
		
		_allow_skidding_delay_timer.start()

func _on_update(delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var horizontal_camera_rotation = _camera.get_horizontal_rotation()
	var direction = _handle_direction_input(horizontal_camera_rotation)
	var will_skid = _handle_skidding(actor, blackboard.get_value("is_skidding_allowed_while_running"), direction)
	if will_skid:
		return
	
	var stats = _character.get_character_stats()
	var agility_stat = stats.get_stat(AGILITY)
	var agility_value = agility_stat.get_value(false)
	var movement_speed_stat = stats.get_substat(MOVEMENT_SPEED)
	var movement_speed_value = movement_speed_stat.sample(agility_value, false)
	var speed = movement_speed_value * _speed_multiplier
	
	var velocity = _handle_running(actor.velocity, direction, speed, delta)
	
	actor.velocity = velocity
	if not velocity.is_zero_approx():
		var velocity_normalized = velocity.normalized()
		_character.rotation.y = atan2(velocity_normalized.x, velocity_normalized.z)
	
	#_handle_targeting(blackboard.get_value("is_targeting"))

func _on_exit(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	var status = actor.get_status()
	
	var particle_system = _playable_character_sprinting_particles.get_node("%GPUParticles3D")
	particle_system.emitting = false
	
	status.stamina_modified.disconnect(_on_status_stamina_modified)
	
	_drain_stamina_timer.timeout.disconnect(_on_drain_stamina_timer_timeout)
	_drain_stamina_timer.paused = true
	
	_allow_skidding_delay_timer.timeout.disconnect(_on_allow_skidding_delay_timer_timeout)
	if not _allow_skidding_delay_timer.is_stopped():
		_allow_skidding_delay_timer.paused = true

func _handle_direction_input(horizontal_rotation: float) -> Vector3:
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	var direction = Vector3(input_direction.x, 0, input_direction.y)
	direction = direction.rotated(Vector3.UP, horizontal_rotation).normalized()
	
	return direction

func _handle_skidding(actor: Node, is_skidding_allowed_while_running: bool, direction: Vector3) -> bool:
	if not is_skidding_allowed_while_running or not _skid_cooldown_timer.is_stopped():
		return false
	
	if direction.is_zero_approx():
		get_parent().fire_event("on_start_skidding")
		return true
	
	var dot = actor.velocity.normalized().dot(direction)
	if dot <= -_skid_threshold:
		get_parent().fire_event("on_start_skidding")
		return true
	
	return false

func _handle_running(current_velocity: Vector3, direction: Vector3, speed: float, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(direction * speed, _acceleration * delta)
	return velocity

func _handle_targeting(is_targeting: bool):
	var character_animation_tree_expression_base = _character.get_node("%CharacterAnimationTreeExpressionBase")
	
	if not is_targeting:
		character_animation_tree_expression_base.travel_to_non_targeting_movement()
		return
	
	character_animation_tree_expression_base.travel_to_targeting_movement()
	var horizontal_camera_rotation = _camera.get_horizontal_rotation()
	_character.rotation.y = horizontal_camera_rotation + PI

func _handle_stamina_drained(status: CharacterStatus, auto_jog: bool) -> bool:
	if not status.is_exhausted():
		return false
	
	if auto_jog:
		get_parent().fire_event("on_start_jogging")
		return true
	
	get_parent().fire_event("on_start_walking")
	return true

func _on_status_stamina_modified(old: int, new: int, status: CharacterStatus, blackboard: BTBlackboard):
	var transitioned = _handle_stamina_drained(status, blackboard.get_value("auto_jog"))

func _on_drain_stamina_timer_timeout(character_status: CharacterStatus):
	character_status.exhaust(_stamina_drain)
	_drain_stamina_timer.start()

func _on_allow_skidding_delay_timer_timeout(blackboard: BTBlackboard):
	blackboard.set_value("is_skidding_allowed_while_running", true)
	#_running_dust_trail.emitting = true
