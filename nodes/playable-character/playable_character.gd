class_name PlayableCharacter
extends CharacterBody3D

const STAMINA_REGENERATION_INTERVAL: float = 0.5

const AGILITY: StringName = &"agility"
const STAMINA_REGENERATION_RATE: StringName = &"stamina_regeneration_rate"

@export var _playable_character_gameplay_ui_packedscene: PackedScene

var _game_manager: GameManager
var _character_switch_cooling_down: bool = false
var _can_switch_characters: bool = true
var _character_attack_state_machine: CharacterAttackStateMachine
var _stamina_regeneration_timer: float = STAMINA_REGENERATION_INTERVAL

var _direction: Vector3
var _relative_direction: Vector3

@onready var _character_switch_cooldown_timer: Timer = %CharacterSwitchCooldownTimer

@onready var _playable_character_combat_manager: PlayableCharacterCombatManager = %PlayableCharacterCombatManager
@onready var _playable_character_visual_controller: PlayableCharacterVisualController = %PlayableCharacterVisualController
@onready var _playable_character_character_container: PlayableCharacterCharacterContainer = %PlayableCharacterCharacterContainer
@onready var _playable_character_camera: PlayableCharacterCamera = %PlayableCharacterCamera
@onready var _playable_character_stamina_meter: PlayableCharacterStaminaMeter = %PlayableCharacterStaminaMeter

@onready var _gameplay_finite_state_machine: FiniteStateMachine = %GameplayFiniteStateMachine
@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine
@onready var _gameplay_blackboard: BTBlackboard = _gameplay_finite_state_machine.blackboard
@onready var _animation_blackboard: BTBlackboard = _animation_finite_state_machine.blackboard

func initialize(game_manager: GameManager) -> void:
	_game_manager = game_manager
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var current_character = _playable_character_character_container.get_current_character()
	_playable_character_stamina_meter.set_character_status(current_character.get_character_status())
	
	_playable_character_combat_manager.initialize(self)
	_playable_character_visual_controller.initialize(self)
	#_setup_character_attack_state_machine(current_character)
	_start_state_machines()
	%PlayableCharacterStatusModifier.initialize()

func _physics_process(delta: float) -> void:
	move_and_slide()

func _process(delta: float) -> void:
	_gameplay_blackboard.set_value("auto_jog", _handle_toggle_auto_jog(_gameplay_blackboard.get_value("auto_jog")))
	
	_handle_stamina_regeneration(_gameplay_blackboard.get_value("regenerate_stamina"), delta)
	
	DebugDraw3D.draw_arrow(global_position, global_position + get_front_direction(), Color.RED)
	DebugDraw3D.draw_arrow(global_position, global_position + get_back_direction(), Color.BLUE)
	DebugDraw3D.draw_arrow(global_position, global_position + get_right_direction(), Color.YELLOW)
	DebugDraw3D.draw_arrow(global_position, global_position + get_left_direction(), Color.GREEN)
	
	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
	_direction = Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3.UP, _playable_character_camera.get_horizontal_rotation()).normalized()
	var dot = _direction.dot(get_front_direction())
	var cross = _direction.cross(get_front_direction())
	_relative_direction = Vector3(cross.y, 0, dot).normalized()
	
	DebugDraw3D.draw_arrow(global_position, global_position + (_direction * 1.5), Color.BLACK, 0.2)
	DebugDraw2D.set_text("relative_direction", str(_relative_direction))

func can_switch_characters() -> bool:
	return _can_switch_characters and (not _character_switch_cooling_down)

func get_character_switch_cooldown_timer() -> Timer:
	return _character_switch_cooldown_timer
func get_character_attack_state_machine() -> CharacterAttackStateMachine:
	return _character_attack_state_machine
func get_playable_character_gameplay_ui_packedscene() -> PackedScene:
	return _playable_character_gameplay_ui_packedscene
func get_playable_character_visual_controller() -> PlayableCharacterVisualController:
	return _playable_character_visual_controller
func get_playable_character_character_container() -> PlayableCharacterCharacterContainer:
	return _playable_character_character_container
func get_playable_character_camera() -> PlayableCharacterCamera:
	return _playable_character_camera

func get_relative_direction() -> Vector3:
	return _relative_direction

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
func get_left_direction() :
	return get_front_direction().rotated(Vector3.UP, PI/2).normalized()
func get_right_direction() :
	return get_front_direction().rotated(Vector3.UP, -PI/2).normalized()
