class_name PlayableCharacterVisualController
extends Node

const SWITCH_CHARACTER_VISUALS_DELAY = 0.3
const PLAYABLE_CHARACTER_GAMEPLAY_UI_SCENE = preload("res://nodes/playable-character/components/playable-character-gameplay-ui/playable_character_gameplay_ui.tscn")

var _playable_character_gameplay_ui_instance: PlayableCharacterGameplayUI
var _playable_character: PlayableCharacter
var _playable_character_character_container: PlayableCharacterCharacterContainer

func _process(delta: float) -> void:
	_handle_update_character_switcher_cooldown_progress()
	_handle_update_character_status_health_bar()
	_handle_update_character_switcher_health_bar()
	_handle_update_character_switcher_stamina_bar()

func initialize(playable_character: PlayableCharacter) -> void:
	_playable_character = playable_character
	_playable_character_character_container = _playable_character.get_playable_character_character_container()
	
	_playable_character_character_container.current_character_changed.connect(_on_current_character_changed)

func get_new_playable_character_gameplay_ui_instance() -> PlayableCharacterGameplayUI:
	if _playable_character_gameplay_ui_instance:
		_dispose_of_current_playable_character_gameplay_ui_instance()
	
	var instance = PLAYABLE_CHARACTER_GAMEPLAY_UI_SCENE.instantiate()
	_playable_character_gameplay_ui_instance = instance
	_setup_playable_character_gameplay_ui_instance()
	_switch_active_character_visuals(null, _playable_character_character_container.get_current_character())
	return _playable_character_gameplay_ui_instance

func get_playable_character_gameplay_ui_instance() -> PlayableCharacterGameplayUI:
	return _playable_character_gameplay_ui_instance

func _setup_playable_character_gameplay_ui_instance() -> void:
	_update_character_switcher_visuals()
	_update_character_status_visual()

func _update_character_switcher_visuals() -> void:
	var character_container = _playable_character.get_playable_character_character_container()
	var characters = character_container.get_characters()
	
	for i in characters.size():
		var character = characters[i]
		var metadata = character.get_character_metadata()
		var character_name = metadata.get_character_name()
		var character_switcher_visual_packedscene = character.get_character_switcher_visual_packedscene()
		
		_playable_character_gameplay_ui_instance.add_character_switcher_visual(
			character_name,
			character_switcher_visual_packedscene,
			str(i + 1))
func _update_character_status_visual():
	var character_container = _playable_character.get_playable_character_character_container()
	var characters = character_container.get_characters()
	
	for i in characters.size():
		var character = characters[i]
		var metadata = character.get_character_metadata()
		var character_name = metadata.get_character_name()
		var character_status_visual_packedscene = character.get_character_status_visual_packedscene()
		
		_playable_character_gameplay_ui_instance.add_character_status_visual(
			character_name,
			character_status_visual_packedscene)

func _on_current_character_changed(old: Character, new: Character):
	_switch_active_character_visuals(old, new)

func _switch_active_character_visuals(old_character: Character, new_character: Character):
	if old_character:
		var old_character_metadata = old_character.get_character_metadata()
		var old_character_name = old_character_metadata.get_character_name()
		var old_character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(old_character_name)
		var old_character_status_visual = _playable_character_gameplay_ui_instance.get_character_status_visual(old_character_name)
		old_character_switcher_visual.switch_off()
		old_character_status_visual.switch_off()
	
	var new_character_metadata = new_character.get_character_metadata()
	var new_character_name = new_character_metadata.get_character_name()
	var new_character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(new_character_name)
	var new_character_status_visual = _playable_character_gameplay_ui_instance.get_character_status_visual(new_character_name)
	new_character_switcher_visual.switch_on()
	await get_tree().create_timer(SWITCH_CHARACTER_VISUALS_DELAY).timeout
	new_character_status_visual.switch_on()
func _handle_update_character_switcher_cooldown_progress():
	var cooldown_timer = _playable_character.get_character_switch_cooldown_timer()
	var cooldown_time_left = cooldown_timer.time_left
	var cooldown_starting_time = cooldown_timer.wait_time
	
	# if the cooldown timer is stopped but for some reason the player cannot switch characters
	# fill the cooldown timer progress bar to give the player a visual that they cannot switch
	# characters at this time.
	if _playable_character.can_switch_characters():
		cooldown_time_left = 0
		cooldown_starting_time = 1
	elif cooldown_timer.is_stopped():
		cooldown_time_left = 1
		cooldown_starting_time = 1
	
	var character_switcher_visuals = _playable_character_gameplay_ui_instance.get_character_switcher_visuals()
	for character_switcher_visual in character_switcher_visuals:
		character_switcher_visual = character_switcher_visual as CharacterSwitcherVisual
		
		character_switcher_visual.update_character_switch_cooldown_progress(cooldown_time_left, cooldown_starting_time)
func _handle_update_character_status_health_bar():
	var character_container = _playable_character.get_playable_character_character_container()
	var characters = character_container.get_characters()
	
	for character in characters:
		var metadata = character.get_character_metadata()
		var character_name = metadata.get_character_name()
		var character_status_visual = _playable_character_gameplay_ui_instance.get_character_status_visual(character_name)
		
		var character_status = character.get_character_status()
		var current_health = character_status.get_health()
		var max_health = character_status.get_max_health()
		
		character_status_visual.update_health_bar(current_health, max_health)
func _handle_update_character_switcher_health_bar():
	var character_container = _playable_character.get_playable_character_character_container()
	var characters = character_container.get_characters()
	
	for character in characters:
		var metadata = character.get_character_metadata()
		var character_name = metadata.get_character_name()
		var character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(character_name)
		
		var character_status = character.get_character_status()
		var current_health = character_status.get_health()
		var max_health = character_status.get_max_health()
		
		character_switcher_visual.update_health_bar(current_health, max_health)
func _handle_update_character_switcher_stamina_bar():
	var character_container = _playable_character.get_playable_character_character_container()
	var characters = character_container.get_characters()
	
	for character in characters:
		var metadata = character.get_character_metadata()
		var character_name = metadata.get_character_name()
		var character_switcher_visual = _playable_character_gameplay_ui_instance.get_character_switcher_visual(character_name)
		
		var character_status = character.get_character_status()
		var current_stamina = character_status.get_stamina()
		var max_stamina = character_status.get_max_stamina()
		
		character_switcher_visual.update_stamina_bar(current_stamina, max_stamina)

func _dispose_of_current_playable_character_gameplay_ui_instance() -> void:
	_playable_character_gameplay_ui_instance.queue_free()
