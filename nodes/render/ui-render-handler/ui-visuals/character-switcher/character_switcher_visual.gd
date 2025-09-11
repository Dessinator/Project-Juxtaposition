@tool
class_name CharacterSwitcherVisual
extends Control

signal switched_on

const EMPTY_CHARACTER_NAME_PLACEHOLDER: String = "Character Name"

@export var _character_icon: Texture2D:
	set(value):
		_character_icon = value
		if not _character_icon:
			%CharacterIconTextureRect.texture = PlaceholderTexture2D.new()
			return
		%CharacterIconTextureRect.texture = _character_icon
@export var _character_name: String:
	set(value):
		_character_name = value
		if _character_name.is_empty():
			%CharacterNameLabel.text = EMPTY_CHARACTER_NAME_PLACEHOLDER
			return
		%CharacterNameLabel.text = _character_name

var _key_hint: String = "0"
var _cached_child_index: int

@onready var _character_icon_texture_rect: TextureRect = %CharacterIconTextureRect
@onready var _character_name_label: Label = %CharacterNameLabel
@onready var _key_hint_label: Label = %KeyHintLabel
@onready var _character_health_bar: StatusBar = %CharacterHealthBar
@onready var _character_stamina_bar: StatusBar = %CharacterStaminaBar
@onready var _character_switch_cooldown_texture_progress_bar: TextureProgressBar = %CharacterSwitchCooldownTextureProgressBar

@onready var _animation_player: AnimationPlayer = %AnimationPlayer

func initialize() -> void:
	pass
	#switch_off()

func switch_on() -> void:
	%AnimationPlayer.play("switch_on")
func switch_off() -> void:
	%AnimationPlayer.play("switch_off")

func set_key_hint(key_hint: String) -> void:
	%KeyHintLabel.text = key_hint

func update_character_switch_cooldown_progress(time_left: float, starting_time: float):
	%CharacterSwitchCooldownTextureProgressBar.max_value = starting_time
	%CharacterSwitchCooldownTextureProgressBar.value = time_left

func update_health_bar(current_health: int, max_health: int):
	%CharacterHealthBar.set_max_value(max_health)
	%CharacterHealthBar.set_current_value(current_health)
func update_stamina_bar(current_stamina: int, max_stamina: int):
	%CharacterStaminaBar.set_max_value(max_stamina)
	%CharacterStaminaBar.set_current_value(current_stamina)
