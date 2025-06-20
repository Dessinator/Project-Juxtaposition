class_name PlayableCharacterGameplayUI
extends Control

const CHARACTER_SWITCHER_VISUAL_SCENE = preload("res://nodes/render/ui-render-handler/ui-visuals/character-switcher/character_switcher_visual.tscn")

var _character_switcher_visuals: Dictionary
var _character_status_visuals: Dictionary

@onready var _character_switcher_visual_container: Control = %CharacterSwitcherVisualContainer
@onready var _character_status_panel_container: Control = %CharacterStatusPanelContainer

func add_character_switcher_visual(character_name: String, character_switcher_visual_packedscene: PackedScene, key_hint: String) -> void:
	var instance = character_switcher_visual_packedscene.instantiate()
	_character_switcher_visuals[character_name] = instance
	instance.set_key_hint(key_hint)
	instance.initialize()
	%CharacterSwitcherVisualContainer.add_child(instance)
func add_character_status_visual(character_name: String, character_status_visual_packedscene: PackedScene):
	var instance = character_status_visual_packedscene.instantiate()
	_character_status_visuals[character_name] = instance
	%CharacterStatusPanelContainer.add_child(instance)

func get_character_switcher_visuals() -> Array:
	return _character_switcher_visuals.values()
func get_character_switcher_visual(character_name: String) -> CharacterSwitcherVisual:
	assert(_character_switcher_visuals.has(character_name), "No CharacterSwitcherVisual exists by name '{characer_name}'".format({"character_name": character_name}))
	return _character_switcher_visuals[character_name]
func get_character_status_visuals() -> Array:
	return _character_status_visuals.values()
func get_character_status_visual(character_name: String) -> CharacterStatusVisual:
	assert(_character_status_visuals.has(character_name), "No CharacterStatusVisual exists by name '{characer_name}'".format({"character_name": character_name}))
	return _character_status_visuals[character_name]

func remove_character_switcher_visual(character_name: String) -> void:
	assert(_character_switcher_visuals.has(character_name), "No CharacterSwitcherVisual exists by name '{characer_name}'".format({"character_name": character_name}))
	var instance = _character_switcher_visuals[character_name]
	_character_switcher_visuals.erase(character_name)
	instance.queue_free()
func remove_character_status_visual(character_name: String) -> void:
	assert(_character_status_visuals.has(character_name), "No CharacterStatusVisual exists by name '{characer_name}'".format({"character_name": character_name}))
	var instance = _character_status_visuals[character_name]
	_character_status_visuals.erase(character_name)
	instance.queue_free()
