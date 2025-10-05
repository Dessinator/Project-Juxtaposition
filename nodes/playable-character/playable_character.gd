class_name PlayableCharacter
extends CharacterBody3D

const STAMINA_REGENERATION_INTERVAL: float = 0.5

const AGILITY: StringName = &"agility"
const STAMINA_REGENERATION_RATE: StringName = &"stamina_regeneration_rate"

## emitted when an action is performed.
signal action_performed(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, holding: bool)
## emitted when an action is interrupted.
signal action_interrupted(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType)
## emitted when an action has concluded.
signal action_concluded(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType)
## emitted when an action is set as unavailable.
signal action_set_unavailable(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType)
## emitted when an action is set as available.
signal action_set_available(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType)
## emitted when an action is set as unavailable for a set period of time in seconds.
signal action_set_unavailable_duration(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, duration_seconds: float)
## emitted when an action is set as available for a set period of time in seconds.
signal action_set_available_duration(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, duration_seconds: float)

var _game_manager: GameManager
var _character_switch_cooling_down: bool = false
var _can_switch_characters: bool = true
var _character_attack_state_machine: CharacterAttackStateMachine
var _stamina_regeneration_timer: float = STAMINA_REGENERATION_INTERVAL

var _direction: Vector3
var _relative_direction: Vector3

@onready var _playable_character_combat_manager: PlayableCharacterCombatManager = %PlayableCharacterCombatManager
@onready var _playable_character_juxtometer_manager: PlayableCharacterJuxtometerManager = %PlayableCharacterJuxtometerManager
@onready var _playable_character_visual_controller: PlayableCharacterVisualController = %PlayableCharacterVisualController
@onready var _playable_character_character_container: PlayableCharacterCharacterContainer = %PlayableCharacterCharacterContainer
@onready var _playable_character_camera: PlayableCharacterCamera = %PlayableCharacterCamera
@onready var _playable_character_stamina_meter: PlayableCharacterStaminaMeter = %PlayableCharacterStaminaMeter

@onready var _gameplay_finite_state_machine: FiniteStateMachine = %GameplayFiniteStateMachine
@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine
@onready var _gameplay_blackboard: BTBlackboard = _gameplay_finite_state_machine.blackboard
@onready var _animation_blackboard: BTBlackboard = _animation_finite_state_machine.blackboard

@onready var _character_switch_cooldown_timer: Timer = %CharacterSwitchCooldownTimer
@onready var _light_charge_threshold_timer: Timer = %LightChargeThresholdTimer
@onready var _heavy_charge_threshold_timer: Timer = %HeavyChargeThresholdTimer

func initialize(game_manager: GameManager) -> void:
	_game_manager = game_manager
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var current_character = _playable_character_character_container.get_current_character()
	_playable_character_stamina_meter.set_character_status(current_character.get_character_status())
	
	_light_charge_threshold_timer.timeout.connect(_on_light_charge_threshold_timer_timeout)
	_heavy_charge_threshold_timer.timeout.connect(_on_heavy_charge_threshold_timer_timeout)
	
	_playable_character_combat_manager.initialize(self)
	_playable_character_juxtometer_manager.initialize(self)
	_playable_character_visual_controller.initialize(self)
	#_setup_character_attack_state_machine(current_character)
	_start_state_machines()
	%PlayableCharacterStatusModifier.initialize()

func _physics_process(delta: float) -> void:
	move_and_slide()

func _process(delta: float) -> void:
	_handle_stamina_regeneration(_gameplay_blackboard.get_value("regenerate_stamina"), delta)
	
	DebugDraw3D.draw_arrow(global_position, global_position + get_front_direction(), Color.RED, 0.1)
	DebugDraw3D.draw_arrow(global_position, global_position + get_back_direction(), Color.BLUE, 0.1)
	DebugDraw3D.draw_arrow(global_position, global_position + get_right_direction(), Color.YELLOW, 0.1)
	DebugDraw3D.draw_arrow(global_position, global_position + get_left_direction(), Color.GREEN, 0.1)
	
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	_direction = Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3.UP, _playable_character_camera.get_horizontal_rotation()).normalized()
	var dot = _direction.dot(get_front_direction())
	var cross = _direction.cross(get_front_direction())
	_relative_direction = Vector3(cross.y, 0, dot).normalized()
	
	DebugDraw3D.draw_arrow(global_position, global_position + (_direction * 1.5), Color.BLACK, 0.25)
	DebugDraw2D.set_text("relative_direction", str(_relative_direction))

func _unhandled_input(event: InputEvent) -> void:
	_gameplay_blackboard.set_value("auto_jog", _handle_toggle_auto_jog(_gameplay_blackboard.get_value("auto_jog")))
	
	var holding_light_attack_input = _gameplay_blackboard.get_value("holding_light_attack_input")
	var holding_heavy_attack_input = _gameplay_blackboard.get_value("holding_heavy_attack_input")
	
	_gameplay_blackboard.set_value("holding_light_attack_input", _handle_holding_light_attack_input(holding_light_attack_input))
	_gameplay_blackboard.set_value("holding_heavy_attack_input", _handle_holding_heavy_attack_input(holding_heavy_attack_input))

func can_switch_characters() -> bool:
	return _can_switch_characters and (not _character_switch_cooling_down)

func get_character_switch_cooldown_timer() -> Timer:
	return _character_switch_cooldown_timer
func get_character_attack_state_machine() -> CharacterAttackStateMachine:
	return _character_attack_state_machine
func get_playable_character_visual_controller() -> PlayableCharacterVisualController:
	return _playable_character_visual_controller
func get_playable_character_character_container() -> PlayableCharacterCharacterContainer:
	return _playable_character_character_container
func get_playable_character_camera() -> PlayableCharacterCamera:
	return _playable_character_camera

func get_relative_direction() -> Vector3:
	return _relative_direction

func emit_action_performed(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, holding: bool):
	action_performed.emit(action_type, holding)
func emit_action_interrupted(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType):
	action_interrupted.emit(action_type)
func emit_action_concluded(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType):
	action_concluded.emit(action_type)
func emit_action_set_unavailable(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType):
	action_set_unavailable.emit(action_type)
func emit_action_set_available(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType):
	action_set_available.emit(action_type)
func emit_action_set_unavailable_duration(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, duration_seconds: float):
	action_set_unavailable_duration.emit(action_type, duration_seconds)
func emit_action_set_available_duration(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, duration_seconds: float):
	action_set_available_duration.emit(action_type, duration_seconds)

func _on_current_character_changed(old: Character, new: Character):
	#_update_character_attack_state_machine(new)
	_handle_character_switch_cooldown()
	_update_stamina_meter_character_status()

func _setup_character_attack_state_machine(current_character: Character):
	assert(current_character.get_character_attack_state_machine(), "Character {character_name} is missing a CharacterAttackStateMachine PackedScene".format({"character_name" : current_character.name}))
	var character_attack_state_machine_packedscene = current_character.get_character_attack_state_machine()
	_character_attack_state_machine = character_attack_state_machine_packedscene.instantiate()
	_character_attack_state_machine.actor = self
	_character_attack_state_machine._character = current_character
	
	add_child(_character_attack_state_machine)
func _update_character_attack_state_machine(new: Character):
	if is_instance_valid(_character_attack_state_machine):
		_character_attack_state_machine.queue_free()

	_setup_character_attack_state_machine(new)
	_character_attack_state_machine.start()

func _start_state_machines():
	#_character_attack_state_machine.start()
	_animation_finite_state_machine.start()
	_gameplay_finite_state_machine.start()

func _handle_toggle_auto_jog(auto_jog: bool) -> bool:
	if not Input.is_action_just_pressed("jog"):
		return auto_jog
	
	return not auto_jog

func _handle_holding_light_attack_input(is_holding: bool) -> bool:
	# Check if the input is our defined "left_click" action
	if Input.is_action_just_pressed("light_attack"):
		# When the button is first pressed, start the timer and reset the hold flag.
		_light_charge_threshold_timer.start()
		return false
	if Input.is_action_just_released("light_attack"):
		# If the button is released before the timer finishes, it's a "press".
		if not is_holding:
			# Stop the timer to prevent the hold action from firing.
			_light_charge_threshold_timer.stop()
			_gameplay_finite_state_machine.fire_event("pressed_light_attack_input")
			return is_holding
		
		return false
	
	return is_holding
func _handle_holding_heavy_attack_input(is_holding: bool) -> bool:
	# Check if the input is our defined "left_click" action
	if Input.is_action_just_pressed("heavy_attack"):
		# When the button is first pressed, start the timer and reset the hold flag.
		_heavy_charge_threshold_timer.start()
		return false
	if Input.is_action_just_released("heavy_attack"):
		# If the button is released before the timer finishes, it's a "press".
		if not is_holding:
			# Stop the timer to prevent the hold action from firing.
			_heavy_charge_threshold_timer.stop()
			_gameplay_finite_state_machine.fire_event("pressed_heavy_attack_input")
			return is_holding
		
		return false
	
	return is_holding

func _handle_stamina_regeneration(regenerate_stamina: bool, delta: float):
	var current_character = _playable_character_character_container.get_current_character()
	var stats = current_character.get_character_stats()
	var status = current_character.get_character_status()
	
	if status.is_stamina_max():
		return
	if not regenerate_stamina:
		return
	if _stamina_regeneration_timer <= 0:
		var agility_stat = stats.get_stat(AGILITY)
		var agility_value = agility_stat.get_value(false)
		var stamina_regeneration_rate_stat = stats.get_substat(STAMINA_REGENERATION_RATE)
		var stamina_regeneration_rate_value = stamina_regeneration_rate_stat.sample(agility_value, false)
		
		status.rest(stamina_regeneration_rate_value)
		_stamina_regeneration_timer = STAMINA_REGENERATION_INTERVAL
	
	_stamina_regeneration_timer -= delta

func _handle_character_switch_cooldown():
	_character_switch_cooling_down = true
	%CharacterSwitchCooldownTimer.start()
	await %CharacterSwitchCooldownTimer.timeout
	_character_switch_cooling_down = false

func _update_stamina_meter_character_status():
	if not _playable_character_character_container:
		return
	
	var current_character = _playable_character_character_container.get_current_character()
	_playable_character_stamina_meter.set_character_status(current_character.get_character_status())

func _on_died():
	pass

func get_front_direction() -> Vector3:
	return Vector3.FORWARD.rotated(Vector3.UP, _playable_character_character_container.global_rotation.y + PI).normalized()
func get_back_direction() -> Vector3:
	return -get_front_direction().normalized()
func get_left_direction() -> Vector3:
	return get_front_direction().rotated(Vector3.UP, PI/2).normalized()
func get_right_direction() -> Vector3:
	return get_front_direction().rotated(Vector3.UP, -PI/2).normalized()

func _on_character_replace_immunity_timer_timeout() -> void:
	_playable_character_character_container.visible = true
	_playable_character_character_container.get_current_character().get_character_status().set_immune(false)

func _on_light_charge_threshold_timer_timeout():
	_gameplay_blackboard.set_value("holding_light_attack_input", true)
func _on_heavy_charge_threshold_timer_timeout():
	_gameplay_blackboard.set_value("holding_heavy_attack_input", true)
