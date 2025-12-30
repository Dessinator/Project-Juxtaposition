@tool
extends FSMState

const PLAYABLE_CHARACTER_GAMEPLAY_UI_SCENE = preload("res://nodes/playable-character/components/playable-character-gameplay-ui/playable_character_gameplay_ui.tscn")

const DAMAGE_CRIT_STATUS_NUMBER_SCENE = preload("res://nodes/status-number/prefabs/damage_crit_status_number.tscn")
const DAMAGE_STATUS_NUMBER_SCENE = preload("res://nodes/status-number/prefabs/damage_status_number.tscn")
const HEAL_STATUS_NUMBER_SCENE = preload("res://nodes/status-number/prefabs/heal_status_number.tscn")

const AVOID_FLASH_PARTICLE_SCENE = preload("res://nodes/particles/combat/warning-flashes/avoid_flash_particle.tscn")
const DODGE_FLASH_PARTICLE_SCENE = preload("res://nodes/particles/combat/warning-flashes/dodge_flash_particle.tscn")
const PARRY_FLASH_PARTICLE_SCENE = preload("res://nodes/particles/combat/warning-flashes/parry_flash_particle.tscn")

const PLACEHOLDER_FLASH_POSITION: Vector3 = Vector3(0, 1.5, 0)
const SWITCH_CHARACTER_VISUALS_DELAY = 0.3

const OPEN_CHARACTER_MENU: String = "open_character_menu"
const OPEN_PARTY_MENU: String = "open_party_menu"
const OPEN_CHARACTER_ARCHIVE_MENU: String = "open_character_archive_menu"

@onready var _playable_character_combat_manager: PlayableCharacterCombatManager = %PlayableCharacterCombatManager
@onready var _playable_character_character_container: PlayableCharacterCharacterContainer = %PlayableCharacterCharacterContainer
@onready var _playable_character_camera: PlayableCharacterCamera = %PlayableCharacterCamera

@onready var _character_switch_cooldown_timer: Timer = %CharacterSwitchCooldownTimer
@onready var _character_replace_immunity_timer: Timer = %CharacterReplaceImmunityTimer

@onready var _gameplay_finite_state_machine: FiniteStateMachine = %GameplayFiniteStateMachine
@onready var _animation_finite_state_machine: FiniteStateMachine = %AnimationFiniteStateMachine

var _playable_character_gameplay_ui_instance: PlayableCharacterGameplayUI

var _internal_immunity_flickering_time: int

@export var _immunity_flickering_time: int

# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# set playable character camera as current
	_playable_character_camera.current = true

	if not _gameplay_finite_state_machine.active:
		_gameplay_finite_state_machine.active = true
	if not _animation_finite_state_machine.active:
		_animation_finite_state_machine.active = true
	
	_setup_signals(actor)

	var game_manager = GameManager.get_instance()

	# instantiate the gameplay ui
	_playable_character_gameplay_ui_instance = PLAYABLE_CHARACTER_GAMEPLAY_UI_SCENE.instantiate()
	_setup_playable_character_gameplay_ui_instance()
	game_manager.get_ui_render_handler().set_ui_scene(_playable_character_gameplay_ui_instance)
	_switch_active_character_visuals(null, _playable_character_character_container.get_current_character())

# Executes every _process call, if the state is active.
func _on_update(_delta: float, actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter
	
	var transitioned = _handle_transitions()
	if transitioned:
		return
	
	_handle_update_character_switcher_cooldown_progress(actor)

# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter

	if _gameplay_finite_state_machine.active:
		_gameplay_finite_state_machine.active = false
	if _animation_finite_state_machine.active:
		_animation_finite_state_machine.active = false
	
	_disconnect_signals(actor)

func _setup_signals(playable_character: PlayableCharacter):
	_character_replace_immunity_timer.timeout.connect(_on_character_replace_immunity_timer_timeout)
	_playable_character_character_container.current_character_changed.connect(_on_current_character_changed.bind(playable_character))
	_playable_character_combat_manager.start_targeting.connect(_on_playable_character_combat_manager_start_targeting)
	_playable_character_combat_manager.stop_targeting.connect(_on_playable_character_combat_manager_stop_targeting)
	
	var current_character = _playable_character_character_container.get_current_character()
	var status = current_character.get_character_status()
	
	status.healed.connect(_on_current_character_healed.bind(playable_character))
	status.damaged.connect(_on_current_character_damaged.bind(playable_character))
	status.about_to_be_damaged.connect(_on_current_character_about_to_be_damaged.bind(current_character))
	playable_character.action_performed.connect(_on_action_performed.bind(current_character))
	playable_character.action_interrupted.connect(_on_action_interrupted.bind(current_character))
	playable_character.action_concluded.connect(_on_action_concluded.bind(current_character))
	playable_character.action_set_unavailable.connect(_on_action_set_unavailable.bind(current_character))
	playable_character.action_set_available.connect(_on_action_set_available.bind(current_character))
	playable_character.action_set_unavailable_duration.connect(_on_action_set_unavailable_duration.bind(current_character))
	playable_character.action_set_available_duration.connect(_on_action_set_available_duration.bind(current_character))
	
	for character in _playable_character_character_container.get_characters():
		var character_status = character.get_character_status()
		var character_data = character.get_character_data()
		
		character_status.health_modified.connect(_on_character_health_modified.bind(character))
		character_status.max_health_modified.connect(_on_character_max_health_modified.bind(character))
		character_status.stamina_modified.connect(_on_character_stamina_modified.bind(character))
		character_status.max_stamina_modified.connect(_on_character_max_stamina_modified.bind(character))
		character_status.juxtometer_modified.connect(_on_current_character_juxtometer_modified.bind(character))

		character_data.experience_level_changed.connect(_on_character_experience_level_changed.bind(character))
func _disconnect_signals(playable_character: PlayableCharacter):
	_character_replace_immunity_timer.timeout.disconnect(_on_character_replace_immunity_timer_timeout)
	_playable_character_character_container.current_character_changed.disconnect(_on_current_character_changed)
	_playable_character_combat_manager.start_targeting.disconnect(_on_playable_character_combat_manager_start_targeting)
	_playable_character_combat_manager.stop_targeting.disconnect(_on_playable_character_combat_manager_stop_targeting)
	
	var current_character = _playable_character_character_container.get_current_character()
	var status = current_character.get_character_status()
	
	status.healed.disconnect(_on_current_character_healed)
	status.damaged.disconnect(_on_current_character_damaged)
	status.about_to_be_damaged.disconnect(_on_current_character_about_to_be_damaged)
	playable_character.action_performed.disconnect(_on_action_performed)
	playable_character.action_interrupted.disconnect(_on_action_interrupted)
	playable_character.action_concluded.disconnect(_on_action_concluded)
	playable_character.action_set_unavailable.disconnect(_on_action_set_unavailable)
	playable_character.action_set_available.disconnect(_on_action_set_available)
	playable_character.action_set_unavailable_duration.disconnect(_on_action_set_unavailable_duration)
	playable_character.action_set_available_duration.disconnect(_on_action_set_available_duration)
	
	for character in _playable_character_character_container.get_characters():
		var character_status = character.get_character_status()
		
		character_status.health_modified.disconnect(_on_character_health_modified)
		character_status.max_health_modified.disconnect(_on_character_max_health_modified)
		character_status.stamina_modified.disconnect(_on_character_stamina_modified)
		character_status.max_stamina_modified.disconnect(_on_character_max_stamina_modified)
		character_status.juxtometer_modified.disconnect(_on_current_character_juxtometer_modified)

func _on_current_character_changed(old: Character, new: Character, playable_character: PlayableCharacter):
	_switch_active_character_visuals(old, new)
	
	if old:
		playable_character.action_performed.disconnect(_on_action_performed)
		playable_character.action_interrupted.disconnect(_on_action_interrupted)
		playable_character.action_concluded.disconnect(_on_action_concluded)
		playable_character.action_set_unavailable.disconnect(_on_action_set_unavailable)
		playable_character.action_set_available.disconnect(_on_action_set_available)
		playable_character.action_set_unavailable_duration.disconnect(_on_action_set_unavailable_duration)
		playable_character.action_set_available_duration.disconnect(_on_action_set_available_duration)
		
		var old_character_status = old.get_character_status()
		old_character_status.healed.disconnect(_on_current_character_healed)
		old_character_status.about_to_be_damaged.disconnect(_on_current_character_about_to_be_damaged)
		old_character_status.damaged.disconnect(_on_current_character_damaged)
	
	playable_character.action_performed.connect(_on_action_performed.bind(new))
	playable_character.action_interrupted.connect(_on_action_interrupted.bind(new))
	playable_character.action_concluded.connect(_on_action_concluded.bind(new))
	playable_character.action_set_unavailable.connect(_on_action_set_unavailable.bind(new))
	playable_character.action_set_available.connect(_on_action_set_available.bind(new))
	playable_character.action_set_unavailable_duration.connect(_on_action_set_unavailable_duration.bind(new))
	playable_character.action_set_available_duration.connect(_on_action_set_available_duration.bind(new))
	
	var new_character_status = new.get_character_status()
	new_character_status.healed.connect(_on_current_character_healed.bind(playable_character))
	new_character_status.about_to_be_damaged.connect(_on_current_character_about_to_be_damaged.bind(new))
	new_character_status.damaged.connect(_on_current_character_damaged.bind(playable_character))

func _setup_playable_character_gameplay_ui_instance() -> void:
	_setup_character_switcher_visuals()
	_setup_character_status_visual()
	_setup_character_action_visuals()
	_setup_all_character_status_information()

func _setup_character_switcher_visuals():
	var characters = _playable_character_character_container.get_characters()
	
	for i in characters.size():
		var character = characters[i]
		var data = character.get_character_data()
		var character_switcher_visual_packedscene = character.get_character_switcher_visual_packedscene()
		
		_playable_character_gameplay_ui_instance.add_character_switcher_visual(
			data.internal_name,
			character_switcher_visual_packedscene,
			str(i + 1))
func _setup_character_status_visual():
	var characters = _playable_character_character_container.get_characters()
	
	for i in characters.size():
		var character = characters[i]
		var data = character.get_character_data()
		var character_status_visual_packedscene = character.get_character_status_visual_packedscene()
		
		_playable_character_gameplay_ui_instance.add_character_status_visual(
			data.internal_name,
			character_status_visual_packedscene)
func _setup_character_action_visuals():
	var characters = _playable_character_character_container.get_characters()
	
	for i in characters.size():
		var character = characters[i]
		var data = character.get_character_data()
		var internal_name = data.internal_name
		
		_playable_character_gameplay_ui_instance.add_character_action_visual(internal_name, character.dodge_character_action_visual_packedscene)
		_playable_character_gameplay_ui_instance.add_character_action_visual(internal_name, character.parry_character_action_visual_packedscene)
		_playable_character_gameplay_ui_instance.add_character_action_visual(internal_name, character.jump_character_action_visual_packedscene)
		_playable_character_gameplay_ui_instance.add_character_action_visual(internal_name, character.light_attack_character_action_visual_packedscene)
		_playable_character_gameplay_ui_instance.add_character_action_visual(internal_name, character.heavy_attack_character_action_visual_packedscene)
		_playable_character_gameplay_ui_instance.add_character_action_visual(internal_name, character.juxtapose_character_action_visual_packedscene)
func _setup_all_character_status_information():
	for character in _playable_character_character_container.get_characters():
		_handle_update_character_status_health_bar(character)
		_handle_update_character_status_juxtometer_bar(character)
		_handle_update_character_status_experience_level(character)
		_handle_update_character_switcher_health_bar(character)
		_handle_update_character_switcher_stamina_bar(character)
		_handle_update_character_switcher_juxtometer_bar(character)

func _switch_active_character_visuals(old_character: Character, new_character: Character):
	if old_character:
		var old_character_data = old_character.get_character_data()
		var old_internal_name = old_character_data.internal_name
		var old_character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(old_internal_name)
		var old_character_status_visual = _playable_character_gameplay_ui_instance.get_character_status_visual(old_internal_name)
		old_character_switcher_visual.switch_off()
		old_character_status_visual.switch_off()
		
		var old_character_action_visuals = _playable_character_gameplay_ui_instance.get_character_action_visuals(old_internal_name)
		for action_visual in old_character_action_visuals:
			action_visual.visible = false
	
	var new_character_data = new_character.get_character_data()
	var new_internal_name = new_character_data.internal_name
	var new_character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(new_internal_name)
	var new_character_status_visual = _playable_character_gameplay_ui_instance.get_character_status_visual(new_internal_name)
	var new_character_action_visuals = _playable_character_gameplay_ui_instance.get_character_action_visuals(new_internal_name)
	for action_visual in new_character_action_visuals:
		action_visual.visible = true
	
	new_character_switcher_visual.switch_on()
	await get_tree().create_timer(SWITCH_CHARACTER_VISUALS_DELAY).timeout
	new_character_status_visual.switch_on()
func _get_matching_action_visual_for_character(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, character: Character) -> CharacterActionVisual:
	if not _playable_character_gameplay_ui_instance:
		return
	
	var data = character.get_character_data()
	var character_action_visuals = _playable_character_gameplay_ui_instance.get_character_action_visuals(data.internal_name)
	
	var matching_action_visual = null
	for action_visual in character_action_visuals:
		if not action_visual.action_visual_type == action_type:
			continue
		matching_action_visual = action_visual
	
	return matching_action_visual

func _on_current_character_damaged(damage_instance: DamageInstance, playable_character: PlayableCharacter):
	if not damage_instance.spawn_damage_number:
		return
	_handle_damage_status_number_instantiation(damage_instance.base_damage, damage_instance.is_crit, playable_character)
func _on_current_character_healed(heal_instance: HealInstance, playable_character: PlayableCharacter):
	if not heal_instance.spawn_heal_number:
		return
	_handle_heal_status_number_instantiation(heal_instance.heal, playable_character)
func _on_current_character_about_to_be_damaged(damage_instance: DamageInstance, interrupt_callback, character: Character):
	# no point in showing a flash if theres no time to interrupt
	if not damage_instance.time_to_interrupt > 0:
		return
	
	var character_status = character.get_character_status()
	var can_parry = character_status.get_stamina() - _playable_character_combat_manager.get_parry_stamina_cost() >= 0
	var can_dodge = character_status.get_stamina() - _playable_character_combat_manager.get_dodge_stamina_cost() >= 0
	
	if (not can_parry) and (not can_dodge):
		var avoid_flash_instance = AVOID_FLASH_PARTICLE_SCENE.instantiate()
		damage_instance.source.add_child(avoid_flash_instance)
		avoid_flash_instance.position = PLACEHOLDER_FLASH_POSITION
		return
	if (not damage_instance.can_parry) and (not damage_instance.can_dodge):
		var avoid_flash_instance = AVOID_FLASH_PARTICLE_SCENE.instantiate()
		damage_instance.source.add_child(avoid_flash_instance)
		avoid_flash_instance.position = PLACEHOLDER_FLASH_POSITION
		return
	
	if damage_instance.can_dodge and (not damage_instance.can_parry):
		if not can_dodge:
			var avoid_flash_instance = AVOID_FLASH_PARTICLE_SCENE.instantiate()
			damage_instance.source.add_child(avoid_flash_instance)
			avoid_flash_instance.position = PLACEHOLDER_FLASH_POSITION
			return
		var dodge_flash_instance = DODGE_FLASH_PARTICLE_SCENE.instantiate()
		damage_instance.source.add_child(dodge_flash_instance)
		dodge_flash_instance.position = PLACEHOLDER_FLASH_POSITION
		return
	if damage_instance.can_parry:
		if not can_parry:
			var avoid_flash_instance = AVOID_FLASH_PARTICLE_SCENE.instantiate()
			damage_instance.source.add_child(avoid_flash_instance)
			avoid_flash_instance.position = PLACEHOLDER_FLASH_POSITION
			return
		var parry_flash_instance = PARRY_FLASH_PARTICLE_SCENE.instantiate()
		damage_instance.source.add_child(parry_flash_instance)
		parry_flash_instance.position = PLACEHOLDER_FLASH_POSITION

func _handle_damage_status_number_instantiation(amount: int, crit: bool, playable_character: PlayableCharacter):
	if crit:
		var instance = DAMAGE_CRIT_STATUS_NUMBER_SCENE.instantiate()
		instance.value = amount
		playable_character.add_child(instance)
		return
	
	var instance = DAMAGE_STATUS_NUMBER_SCENE.instantiate()
	instance.value = amount
	playable_character.add_child(instance)
func _handle_heal_status_number_instantiation(amount: int, playable_character: PlayableCharacter):
	var instance = HEAL_STATUS_NUMBER_SCENE.instantiate()
	instance.value = amount
	playable_character.add_child(instance)

func _on_character_max_health_modified(_old: int, _new: int, character: Character):
	_handle_update_character_status_health_bar(character)
	_handle_update_character_switcher_health_bar(character)
func _on_character_health_modified(_old: int, _new: int, character: Character):
	_handle_update_character_status_health_bar(character)
	_handle_update_character_switcher_health_bar(character)
func _on_character_max_stamina_modified(_old: int, _new: int, character: Character):
	_handle_update_character_switcher_stamina_bar(character)
func _on_character_stamina_modified(_old: int, _new: int, character: Character):
	_handle_update_character_switcher_stamina_bar(character)
func _on_current_character_juxtometer_modified(old: float, new: float, character: Character):
	_handle_update_character_status_juxtometer_bar(character)
	_handle_update_character_switcher_juxtometer_bar(character)

func _on_character_experience_level_changed(character: Character):
	_handle_update_character_status_experience_level(character)

func _handle_update_character_status_health_bar(character: Character):
	var data = character.get_character_data()
	var character_status_visual = _playable_character_gameplay_ui_instance.get_character_status_visual(data.internal_name)
	
	var character_status = character.get_character_status()
	var current_health = character_status.get_health()
	var max_health = character_status.get_max_health()
	
	character_status_visual.update_health_bar(current_health, max_health)
func _handle_update_character_status_juxtometer_bar(character: Character):
	var data = character.get_character_data()
	var character_status_visual = _playable_character_gameplay_ui_instance.get_character_status_visual(data.internal_name)
	
	var character_status = character.get_character_status()
	var current_juxtometer_reading = character_status.get_juxtometer_reading()
	character_status_visual.update_juxtometer_bar(current_juxtometer_reading)

func _handle_update_character_status_experience_level(character: Character):
	var data = character.get_character_data()
	var character_status_visual = _playable_character_gameplay_ui_instance.get_character_status_visual(data.internal_name)

	character_status_visual.update_experience_level(data.experience_level)

func _handle_update_character_switcher_health_bar(character: Character):
	var data = character.get_character_data()
	var character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(data.internal_name)
	
	var character_status = character.get_character_status()
	var current_health = character_status.get_health()
	var max_health = character_status.get_max_health()
	
	character_switcher_visual.update_health_bar(current_health, max_health)
func _handle_update_character_switcher_stamina_bar(character: Character):
	var data = character.get_character_data()
	var character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(data.internal_name)
	
	var character_status = character.get_character_status()
	var current_stamina = character_status.get_stamina()
	var max_stamina = character_status.get_max_stamina()
	
	character_switcher_visual.update_stamina_bar(current_stamina, max_stamina)
func _handle_update_character_switcher_juxtometer_bar(character: Character):
	var data = character.get_character_data()
	var character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(data.internal_name)
	
	var character_status = character.get_character_status()
	var current_juxtometer_reading = character_status.get_juxtometer_reading()
	character_switcher_visual.update_juxtometer_bar(current_juxtometer_reading)

func _handle_update_character_switcher_cooldown_progress(playable_character: PlayableCharacter):
	var cooldown_time_left = _character_switch_cooldown_timer.time_left
	var cooldown_starting_time = _character_switch_cooldown_timer.wait_time
	
	# if the cooldown timer is stopped but for some reason the player cannot switch characters
	# fill the cooldown timer progress bar to give the player a visual that they cannot switch
	# characters at this time.
	if playable_character.can_switch_characters():
		cooldown_time_left = 0
		cooldown_starting_time = 1
	elif _character_switch_cooldown_timer.is_stopped():
		cooldown_time_left = 1
		cooldown_starting_time = 1
	
	var character_switcher_visuals = _playable_character_gameplay_ui_instance.get_character_switcher_visuals()
	for character_switcher_visual in character_switcher_visuals:
		character_switcher_visual = character_switcher_visual as CharacterSwitcherVisual
		
		character_switcher_visual.update_character_switch_cooldown_progress(cooldown_time_left, cooldown_starting_time)

func _on_action_performed(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, holding: bool, character: Character):
	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
	if not matching_action_visual:
		return
	
	if not holding:
		matching_action_visual.press()
		return
	matching_action_visual.hold()
func _on_action_interrupted(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, character: Character):
	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
	if not matching_action_visual:
		return
	matching_action_visual.release()
func _on_action_concluded(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, character: Character):
	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
	if not matching_action_visual:
		return
	matching_action_visual.release()
func _on_action_set_unavailable(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, character: Character):
	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
	if not matching_action_visual:
		return
	matching_action_visual.set_unavailable()
func _on_action_set_available(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, character: Character):
	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
	if not matching_action_visual:
		return
	matching_action_visual.set_available()
func _on_action_set_unavailable_duration(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, duration_seconds: float, character: Character):
	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
	if not matching_action_visual:
		return
	matching_action_visual.set_unavailable_duration(duration_seconds)
func _on_action_set_available_duration(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, duration_seconds: float, character: Character):
	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
	if not matching_action_visual:
		return
	matching_action_visual.set_available_duration(duration_seconds)

func _on_playable_character_combat_manager_start_targeting() -> void:
	GameManager.get_instance().get_ui_render_handler().get_cinematic_bars().activate()
func _on_playable_character_combat_manager_stop_targeting() -> void:
	GameManager.get_instance().get_ui_render_handler().get_cinematic_bars().deactivate()

func _handle_replacement_immunity_flickering():
	if not _character_replace_immunity_timer.is_stopped():
		_internal_immunity_flickering_time += 1
		if _internal_immunity_flickering_time >= _immunity_flickering_time:
			_internal_immunity_flickering_time = 0
			_playable_character_character_container.visible = !_playable_character_character_container.visible
func _on_character_replace_immunity_timer_timeout() -> void:
	_playable_character_character_container.visible = true
	_playable_character_character_container.get_current_character().get_character_status().set_immune(false)

func _handle_transitions() -> bool:
	if Input.is_action_just_pressed("open_character_menu"):
		get_parent().fire_event("open_character_menu")
		return true

	if Input.is_action_just_pressed("open_party_menu"):
		get_parent().fire_event("open_party_menu")
		return true

	# if Input.is_action_just_pressed("open_character_archive_menu"):
	# 	get_parent().fire_event("open_character_archive_menu")

	return false
