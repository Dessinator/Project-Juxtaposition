class_name PlayableCharacterVisualController
extends Node

# const SWITCH_CHARACTER_VISUALS_DELAY = 0.3

# const DAMAGE_CRIT_STATUS_NUMBER_SCENE = preload("res://nodes/status-number/prefabs/damage_crit_status_number.tscn")
# const DAMAGE_STATUS_NUMBER_SCENE = preload("res://nodes/status-number/prefabs/damage_status_number.tscn")
# const HEAL_STATUS_NUMBER_SCENE = preload("res://nodes/status-number/prefabs/heal_status_number.tscn")

# const PLACEHOLDER_FLASH_POSITION: Vector3 = Vector3(0, 1.5, 0)
# const AVOID_FLASH_PARTICLE_SCENE = preload("res://nodes/particles/combat/warning-flashes/avoid_flash_particle.tscn")
# const DODGE_FLASH_PARTICLE_SCENE = preload("res://nodes/particles/combat/warning-flashes/dodge_flash_particle.tscn")
# const PARRY_FLASH_PARTICLE_SCENE = preload("res://nodes/particles/combat/warning-flashes/parry_flash_particle.tscn")

@onready var _playable_character_combat_manager: PlayableCharacterCombatManager = %PlayableCharacterCombatManager
@onready var _character_replace_immunity_timer: Timer = %CharacterReplaceImmunityTimer
@onready var _gameplay_finite_state_machine: FiniteStateMachine = %GameplayFiniteStateMachine

var _playable_character_gameplay_ui_instance: PlayableCharacterGameplayUI
var _playable_character_character_stage_instance: PlayableCharacterCharacterStage
var _playable_character_character_ui_instance: PlayableCharacterCharacterUI

var _playable_character: PlayableCharacter
var _playable_character_character_container: PlayableCharacterCharacterContainer

# var _internal_immunity_flickering_time: int

# @export var _immunity_flickering_time: int

# func _process(delta: float) -> void:
	# _handle_update_character_switcher_cooldown_progress()
	# _handle_replacement_immunity_flickering()

func initialize(playable_character: PlayableCharacter) -> void:
	_playable_character = playable_character
	# _setup_signals()

func get_new_playable_character_gameplay_ui_instance() -> PlayableCharacterGameplayUI:
	return null
	# if _playable_character_gameplay_ui_instance:
	# 	_dispose_of_current_playable_character_gameplay_ui_instance()
	
	# var instance = PLAYABLE_CHARACTER_GAMEPLAY_UI_SCENE.instantiate()
	# _playable_character_gameplay_ui_instance = instance
	# _setup_playable_character_gameplay_ui_instance()
	# _switch_active_character_visuals(null, _playable_character_character_container.get_current_character())
	# return _playable_character_gameplay_ui_instance

# func get_playable_character_gameplay_ui_instance() -> PlayableCharacterGameplayUI:
# 	return _playable_character_gameplay_ui_instance

# func _setup_playable_character_gameplay_ui_instance() -> void:
# 	_update_character_switcher_visuals()
# 	_update_character_status_visual()
# 	_update_character_action_visuals()
# 	_update_all_character_visuals()

# func _setup_signals():
# 	_playable_character_character_container = _playable_character.get_playable_character_character_container()
# 	_playable_character_character_container.current_character_changed.connect(_on_current_character_changed)
	
# 	var current_character = _playable_character_character_container.get_current_character()
# 	var status = current_character.get_character_status()
	
# 	status.healed.connect(_on_current_character_healed)
# 	status.damaged.connect(_on_current_character_damaged)
# 	status.about_to_be_damaged.connect(_on_current_character_about_to_be_damaged.bind(current_character))
# 	_playable_character.action_performed.connect(_on_action_performed.bind(current_character))
# 	_playable_character.action_interrupted.connect(_on_action_interrupted.bind(current_character))
# 	_playable_character.action_concluded.connect(_on_action_concluded.bind(current_character))
# 	_playable_character.action_set_unavailable.connect(_on_action_set_unavailable.bind(current_character))
# 	_playable_character.action_set_available.connect(_on_action_set_available.bind(current_character))
# 	_playable_character.action_set_unavailable_duration.connect(_on_action_set_unavailable_duration.bind(current_character))
# 	_playable_character.action_set_available_duration.connect(_on_action_set_available_duration.bind(current_character))
	
# 	for character in _playable_character_character_container.get_characters():
# 		var character_status = character.get_character_status()
		
# 		character_status.health_modified.connect(_on_character_health_modified.bind(character))
# 		character_status.max_health_modified.connect(_on_character_max_health_modified.bind(character))
# 		character_status.stamina_modified.connect(_on_character_stamina_modified.bind(character))
# 		character_status.max_stamina_modified.connect(_on_character_max_stamina_modified.bind(character))
# 		character_status.juxtometer_modified.connect(_on_current_character_juxtometer_modified.bind(character))

# func _update_all_character_visuals():
# 	for character in _playable_character_character_container.get_characters():
# 		_handle_update_character_status_health_bar(character)
# 		_handle_update_character_status_juxtometer_bar(character)
# 		_handle_update_character_switcher_health_bar(character)
# 		_handle_update_character_switcher_stamina_bar(character)
# 		_handle_update_character_switcher_juxtometer_bar(character)

# func _update_character_status_visual():
# 	var character_container = _playable_character.get_playable_character_character_container()
# 	var characters = character_container.get_characters()
	
# 	for i in characters.size():
# 		var character = characters[i]
# 		var metadata = character.get_character_metadata()
# 		var character_name = metadata.get_character_name()
# 		var character_status_visual_packedscene = character.get_character_status_visual_packedscene()
		
# 		_playable_character_gameplay_ui_instance.add_character_status_visual(
# 			character_name,
# 			character_status_visual_packedscene)
# func _update_character_switcher_visuals():
# 	var character_container = _playable_character.get_playable_character_character_container()
# 	var characters = character_container.get_characters()
	
# 	for i in characters.size():
# 		var character = characters[i]
# 		var metadata = character.get_character_metadata()
# 		var character_name = metadata.get_character_name()
# 		var character_switcher_visual_packedscene = character.get_character_switcher_visual_packedscene()
		
# 		_playable_character_gameplay_ui_instance.add_character_switcher_visual(
# 			character_name,
# 			character_switcher_visual_packedscene,
# 			str(i + 1))
# func _update_character_action_visuals():
# 	var character_container = _playable_character.get_playable_character_character_container()
# 	var characters = character_container.get_characters()
	
# 	for i in characters.size():
# 		var character = characters[i]
# 		var metadata = character.get_character_metadata()
# 		var character_name = metadata.get_character_name()
		
# 		_playable_character_gameplay_ui_instance.add_character_action_visual(character_name, character.dodge_character_action_visual_packedscene)
# 		_playable_character_gameplay_ui_instance.add_character_action_visual(character_name, character.parry_character_action_visual_packedscene)
# 		_playable_character_gameplay_ui_instance.add_character_action_visual(character_name, character.jump_character_action_visual_packedscene)
# 		_playable_character_gameplay_ui_instance.add_character_action_visual(character_name, character.light_attack_character_action_visual_packedscene)
# 		_playable_character_gameplay_ui_instance.add_character_action_visual(character_name, character.heavy_attack_character_action_visual_packedscene)
# 		_playable_character_gameplay_ui_instance.add_character_action_visual(character_name, character.juxtapose_character_action_visual_packedscene)

# func _on_current_character_changed(old: Character, new: Character):
# 	_switch_active_character_visuals(old, new)
	
# 	if old:
# 		_playable_character.action_performed.disconnect(_on_action_performed)
# 		_playable_character.action_interrupted.disconnect(_on_action_interrupted)
# 		_playable_character.action_concluded.disconnect(_on_action_concluded)
# 		_playable_character.action_set_unavailable.disconnect(_on_action_set_unavailable)
# 		_playable_character.action_set_available.disconnect(_on_action_set_available)
# 		_playable_character.action_set_unavailable_duration.disconnect(_on_action_set_unavailable_duration)
# 		_playable_character.action_set_available_duration.disconnect(_on_action_set_available_duration)
		
# 		var old_character_status = old.get_character_status()
# 		old_character_status.healed.disconnect(_on_current_character_healed)
# 		old_character_status.about_to_be_damaged.disconnect(_on_current_character_about_to_be_damaged)
# 		old_character_status.damaged.disconnect(_on_current_character_damaged)
	
# 	_playable_character.action_performed.connect(_on_action_performed.bind(new))
# 	_playable_character.action_interrupted.connect(_on_action_interrupted.bind(new))
# 	_playable_character.action_concluded.connect(_on_action_concluded.bind(new))
# 	_playable_character.action_set_unavailable.connect(_on_action_set_unavailable.bind(new))
# 	_playable_character.action_set_available.connect(_on_action_set_available.bind(new))
# 	_playable_character.action_set_unavailable_duration.connect(_on_action_set_unavailable_duration.bind(new))
# 	_playable_character.action_set_available_duration.connect(_on_action_set_available_duration.bind(new))
	
# 	var new_character_status = new.get_character_status()
# 	new_character_status.healed.connect(_on_current_character_healed)
# 	new_character_status.about_to_be_damaged.connect(_on_current_character_about_to_be_damaged.bind(new))
# 	new_character_status.damaged.connect(_on_current_character_damaged)

# func _on_character_max_health_modified(_old: int, _new: int, character: Character):
# 	_handle_update_character_status_health_bar(character)
# 	_handle_update_character_switcher_health_bar(character)
# func _on_character_health_modified(_old: int, _new: int, character: Character):
# 	_handle_update_character_status_health_bar(character)
# 	_handle_update_character_switcher_health_bar(character)
# func _on_character_max_stamina_modified(_old: int, _new: int, character: Character):
# 	_handle_update_character_switcher_stamina_bar(character)
# func _on_character_stamina_modified(_old: int, _new: int, character: Character):
# 	_handle_update_character_switcher_stamina_bar(character)
# func _on_current_character_juxtometer_modified(old: float, new: float, character: Character):
# 	_handle_update_character_status_juxtometer_bar(character)
# 	_handle_update_character_switcher_juxtometer_bar(character)

# func _switch_active_character_visuals(old_character: Character, new_character: Character):
# 	if old_character:
# 		var old_character_metadata = old_character.get_character_metadata()
# 		var old_character_name = old_character_metadata.get_character_name()
# 		var old_character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(old_character_name)
# 		var old_character_status_visual = _playable_character_gameplay_ui_instance.get_character_status_visual(old_character_name)
# 		old_character_switcher_visual.switch_off()
# 		old_character_status_visual.switch_off()
		
# 		var old_character_action_visuals = _playable_character_gameplay_ui_instance.get_character_action_visuals(old_character_name)
# 		for action_visual in old_character_action_visuals:
# 			action_visual.visible = false
	
# 	var new_character_metadata = new_character.get_character_metadata()
# 	var new_character_name = new_character_metadata.get_character_name()
# 	var new_character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(new_character_name)
# 	var new_character_status_visual = _playable_character_gameplay_ui_instance.get_character_status_visual(new_character_name)
# 	var new_character_action_visuals = _playable_character_gameplay_ui_instance.get_character_action_visuals(new_character_name)
# 	for action_visual in new_character_action_visuals:
# 		action_visual.visible = true
	
# 	new_character_switcher_visual.switch_on()
# 	await get_tree().create_timer(SWITCH_CHARACTER_VISUALS_DELAY).timeout
# 	new_character_status_visual.switch_on()
# func _handle_update_character_switcher_cooldown_progress():
# 	var cooldown_timer = _playable_character.get_character_switch_cooldown_timer()
# 	var cooldown_time_left = cooldown_timer.time_left
# 	var cooldown_starting_time = cooldown_timer.wait_time
	
# 	# if the cooldown timer is stopped but for some reason the player cannot switch characters
# 	# fill the cooldown timer progress bar to give the player a visual that they cannot switch
# 	# characters at this time.
# 	if _playable_character.can_switch_characters():
# 		cooldown_time_left = 0
# 		cooldown_starting_time = 1
# 	elif cooldown_timer.is_stopped():
# 		cooldown_time_left = 1
# 		cooldown_starting_time = 1
	
# 	var character_switcher_visuals = _playable_character_gameplay_ui_instance.get_character_switcher_visuals()
# 	for character_switcher_visual in character_switcher_visuals:
# 		character_switcher_visual = character_switcher_visual as CharacterSwitcherVisual
		
# 		character_switcher_visual.update_character_switch_cooldown_progress(cooldown_time_left, cooldown_starting_time)
# func _handle_update_character_status_health_bar(character: Character):
# 	var metadata = character.get_character_metadata()
# 	var character_name = metadata.get_character_name()
# 	var character_status_visual = _playable_character_gameplay_ui_instance.get_character_status_visual(character_name)
	
# 	var character_status = character.get_character_status()
# 	var current_health = character_status.get_health()
# 	var max_health = character_status.get_max_health()
	
# 	character_status_visual.update_health_bar(current_health, max_health)
# func _handle_update_character_status_juxtometer_bar(character: Character):
# 	var metadata = character.get_character_metadata()
# 	var character_name = metadata.get_character_name()
# 	var character_status_visual = _playable_character_gameplay_ui_instance.get_character_status_visual(character_name)
	
# 	var character_status = character.get_character_status()
# 	var current_juxtometer_reading = character_status.get_juxtometer_reading()
# 	character_status_visual.update_juxtometer_bar(current_juxtometer_reading)

# func _handle_update_character_switcher_health_bar(character: Character):
# 	var metadata = character.get_character_metadata()
# 	var character_name = metadata.get_character_name()
# 	var character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(character_name)
	
# 	var character_status = character.get_character_status()
# 	var current_health = character_status.get_health()
# 	var max_health = character_status.get_max_health()
	
# 	character_switcher_visual.update_health_bar(current_health, max_health)
# func _handle_update_character_switcher_stamina_bar(character: Character):
# 	var metadata = character.get_character_metadata()
# 	var character_name = metadata.get_character_name()
# 	var character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(character_name)
	
# 	var character_status = character.get_character_status()
# 	var current_stamina = character_status.get_stamina()
# 	var max_stamina = character_status.get_max_stamina()
	
# 	character_switcher_visual.update_stamina_bar(current_stamina, max_stamina)
# func _handle_update_character_switcher_juxtometer_bar(character: Character):
# 	var metadata = character.get_character_metadata()
# 	var character_name = metadata.get_character_name()
# 	var character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(character_name)
	
# 	var character_status = character.get_character_status()
# 	var current_juxtometer_reading = character_status.get_juxtometer_reading()
# 	character_switcher_visual.update_juxtometer_bar(current_juxtometer_reading)

# func _get_matching_action_visual_for_character(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, character: Character) -> CharacterActionVisual:
# 	if not _playable_character_gameplay_ui_instance:
# 		return
	
# 	var metadata = character.get_character_metadata()
# 	var character_name = metadata.get_character_name()
# 	var character_action_visuals = _playable_character_gameplay_ui_instance.get_character_action_visuals(character_name)
	
# 	var matching_action_visual = null
# 	for action_visual in character_action_visuals:
# 		if not action_visual.action_visual_type == action_type:
# 			continue
# 		matching_action_visual = action_visual
	
# 	return matching_action_visual

# func _on_action_performed(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, holding: bool, character: Character):
# 	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
# 	if not matching_action_visual:
# 		return
	
# 	if not holding:
# 		matching_action_visual.press()
# 		return
# 	matching_action_visual.hold()
# func _on_action_interrupted(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, character: Character):
# 	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
# 	if not matching_action_visual:
# 		return
# 	matching_action_visual.release()
# func _on_action_concluded(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, character: Character):
# 	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
# 	if not matching_action_visual:
# 		return
# 	matching_action_visual.release()
# func _on_action_set_unavailable(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, character: Character):
# 	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
# 	if not matching_action_visual:
# 		return
# 	matching_action_visual.set_unavailable()
# func _on_action_set_available(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, character: Character):
# 	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
# 	if not matching_action_visual:
# 		return
# 	matching_action_visual.set_available()
# func _on_action_set_unavailable_duration(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, duration_seconds: float, character: Character):
# 	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
# 	if not matching_action_visual:
# 		return
# 	matching_action_visual.set_unavailable_duration(duration_seconds)
# func _on_action_set_available_duration(action_type: PlayableCharacterGameplayState.PlayableCharacterActionType, duration_seconds: float, character: Character):
# 	var matching_action_visual = _get_matching_action_visual_for_character(action_type, character)
# 	if not matching_action_visual:
# 		return
# 	matching_action_visual.set_available_duration(duration_seconds)

# func _handle_replacement_immunity_flickering():
# 	if not _character_replace_immunity_timer.is_stopped():
# 		_internal_immunity_flickering_time += 1
# 		if _internal_immunity_flickering_time >= _immunity_flickering_time:
# 			_internal_immunity_flickering_time = 0
# 			_playable_character_character_container.visible = !_playable_character_character_container.visible

# func _on_current_character_damaged(damage_instance: DamageInstance):
# 	if not damage_instance.spawn_damage_number:
# 		return
# 	_handle_damage_status_number_instantiation(damage_instance.base_damage, damage_instance.is_crit)
# func _on_current_character_healed(heal_instance: HealInstance):
# 	if not heal_instance.spawn_heal_number:
# 		return
# 	_handle_heal_status_number_instantiation(heal_instance.heal)
# func _handle_damage_status_number_instantiation(amount: int, crit: bool):
# 	if crit:
# 		var instance = DAMAGE_CRIT_STATUS_NUMBER_SCENE.instantiate()
# 		instance.value = amount
# 		_playable_character.add_child(instance)
# 		return
	
# 	var instance = DAMAGE_STATUS_NUMBER_SCENE.instantiate()
# 	instance.value = amount
# 	_playable_character.add_child(instance)
# func _handle_heal_status_number_instantiation(amount: int):
# 	var instance = HEAL_STATUS_NUMBER_SCENE.instantiate()
# 	instance.value = amount
# 	_playable_character.add_child(instance)

# func _on_current_character_about_to_be_damaged(damage_instance: DamageInstance, interrupt_callback, character: Character):
# 	# no point in showing a flash if theres no time to interrupt
# 	if not damage_instance.time_to_interrupt > 0:
# 		return
	
# 	var character_status = character.get_character_status()
# 	var can_parry = character_status.get_stamina() - _playable_character_combat_manager.get_parry_stamina_cost() >= 0
# 	var can_dodge = character_status.get_stamina() - _playable_character_combat_manager.get_dodge_stamina_cost() >= 0
	
# 	if (not can_parry) and (not can_dodge):
# 		var avoid_flash_instance = AVOID_FLASH_PARTICLE_SCENE.instantiate()
# 		damage_instance.source.add_child(avoid_flash_instance)
# 		avoid_flash_instance.position = PLACEHOLDER_FLASH_POSITION
# 		return
# 	if (not damage_instance.can_parry) and (not damage_instance.can_dodge):
# 		var avoid_flash_instance = AVOID_FLASH_PARTICLE_SCENE.instantiate()
# 		damage_instance.source.add_child(avoid_flash_instance)
# 		avoid_flash_instance.position = PLACEHOLDER_FLASH_POSITION
# 		return
	
# 	if damage_instance.can_dodge and (not damage_instance.can_parry):
# 		if not can_dodge:
# 			var avoid_flash_instance = AVOID_FLASH_PARTICLE_SCENE.instantiate()
# 			damage_instance.source.add_child(avoid_flash_instance)
# 			avoid_flash_instance.position = PLACEHOLDER_FLASH_POSITION
# 			return
# 		var dodge_flash_instance = DODGE_FLASH_PARTICLE_SCENE.instantiate()
# 		damage_instance.source.add_child(dodge_flash_instance)
# 		dodge_flash_instance.position = PLACEHOLDER_FLASH_POSITION
# 		return
# 	if damage_instance.can_parry:
# 		if not can_parry:
# 			var avoid_flash_instance = AVOID_FLASH_PARTICLE_SCENE.instantiate()
# 			damage_instance.source.add_child(avoid_flash_instance)
# 			avoid_flash_instance.position = PLACEHOLDER_FLASH_POSITION
# 			return
# 		var parry_flash_instance = PARRY_FLASH_PARTICLE_SCENE.instantiate()
# 		damage_instance.source.add_child(parry_flash_instance)
# 		parry_flash_instance.position = PLACEHOLDER_FLASH_POSITION

func _dispose_of_current_playable_character_gameplay_ui_instance() -> void:
	_playable_character_gameplay_ui_instance.queue_free()

# func _on_playable_character_combat_manager_start_targeting() -> void:
# 	GameManager.get_instance().get_ui_render_handler().get_cinematic_bars().activate()
# func _on_playable_character_combat_manager_stop_targeting() -> void:
# 	GameManager.get_instance().get_ui_render_handler().get_cinematic_bars().deactivate()
