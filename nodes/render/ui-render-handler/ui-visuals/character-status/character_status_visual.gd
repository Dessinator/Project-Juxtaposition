@tool
class_name CharacterStatusVisual
extends Control

const EMPTY_CHARACTER_NAME_PLACEHOLDER: String = "Character Name"

@export var _character_name: String:
	set(value):
		if not Engine.is_editor_hint():
			return
		
		_character_name = value
		if _character_name.is_empty():
			%CharacterNameLabel.text = EMPTY_CHARACTER_NAME_PLACEHOLDER
			return
		%CharacterNameLabel.text = _character_name
@export var _character_portrait: Texture2D:
	set(value):
		if not Engine.is_editor_hint():
			return
		
		_character_portrait = value
		if not _character_portrait:
			%CharacterPortraitTextureRect.texture = PlaceholderTexture2D.new()
			return
		%CharacterPortraitTextureRect.texture = _character_portrait

@onready var _character_portrait_texture_rect: TextureRect = %CharacterPortraitTextureRect
@onready var _character_callout_container: Control = %CharacterCalloutContainer
@onready var _character_name_label: Label = %CharacterNameLabel
@onready var _character_level_label: Label = %CharacterLevelLabel
@onready var _character_health_bar: CharacterStatusBar = %CharacterHealthBar
@onready var _character_status_effect_visual_container: HBoxContainer = %CharacterStatusEffectVisualContainer

func _ready() -> void:
	pass
	#switch_off()

func switch_on() -> void:
	%AnimationPlayer.play("switch_on")
func switch_off() -> void:
	%AnimationPlayer.play("switch_off")

func update_health_bar(current_health: int, max_health: int):
	_character_health_bar.set_current_value(current_health)
	_character_health_bar.set_max_value(max_health)
