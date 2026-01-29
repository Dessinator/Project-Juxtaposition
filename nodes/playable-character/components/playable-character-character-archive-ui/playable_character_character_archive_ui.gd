class_name PlayableCharacterCharacterArchiveUI
extends Control

const CHARACTER_PARTY_SELECT_BUTTON_SCENE: PackedScene = preload("res://nodes/render/ui-render-handler/buttons/character-party-member-select-button/character_party_member_select_button.tscn")

signal character_change_requested(internal_name: StringName)
signal close_requested

@onready var _character_party_member_select_buttons_grid_container: GridContainer = %CharacterPartyMemberSelectButtonsGridContainer

@onready var _character_info_panel_container: PanelContainer = %CharacterInfoPanelContainer
@onready var _character_portrait_texture_rect: TextureRect = %CharacterPortraitTextureRect
@onready var _character_nickname_label: Label = %CharacterNicknameLabel
@onready var _character_level_label: Label = %CharacterLevelLabel

var current_character_internal_name: StringName:
	set(value):
		current_character_internal_name = value

		if current_character_internal_name.is_empty():
			_character_info_panel_container.visible = false
			return
		
		var character_packet = Characters.get_character_packet(current_character_internal_name)
		
		_character_info_panel_container.visible = true
		
		if character_packet.character_data.portrait:
			_character_portrait_texture_rect.texture = character_packet.character_data.portrait
		_character_portrait_texture_rect.texture = PlaceholderTexture2D.new()
		_character_nickname_label.text = "\""+character_packet.character_data.nickname+"\""
		_character_level_label.text = "Lv. "+str(character_packet.character_data.experience_level)

		_character_party_member_select_buttons[current_character_internal_name].button.set_pressed_no_signal(true)

var _character_party_member_select_button_group: ButtonGroup
var _character_party_member_select_buttons: Dictionary[StringName, CharacterPartyMemberSelectButton]

@export var _hideable_ui_objects: Array[Control]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_fill_character_select_panel()
	# _setup_character_select_panel()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _fill_character_select_panel():
	_character_party_member_select_button_group = ButtonGroup.new()
	_character_party_member_select_button_group.allow_unpress = false

	for character_packet: CharacterPacket in Characters.get_all_character_packets():
		var character_data = character_packet.character_data
		var internal_name = character_data.internal_name
		var character_party_select_button_instance: CharacterPartyMemberSelectButton = CHARACTER_PARTY_SELECT_BUTTON_SCENE.instantiate()
		_character_party_member_select_buttons_grid_container.add_child(character_party_select_button_instance)

		if internal_name == current_character_internal_name:
			character_party_select_button_instance.button.set_pressed_no_signal(true)

		character_party_select_button_instance.button.button_group = _character_party_member_select_button_group
		character_party_select_button_instance.button.disabled = false

		character_party_select_button_instance.character_portrait = character_data.portrait
		character_party_select_button_instance.character_nickname = character_data.nickname
		character_party_select_button_instance.character_level = character_data.experience_level

		_character_party_member_select_buttons[internal_name] = character_party_select_button_instance

		character_party_select_button_instance.button.toggled.connect(_on_character_party_member_select_button_toggled.bind(internal_name))

func _on_character_party_member_select_button_toggled(toggled_on: bool, internal_name: StringName):
	if not toggled_on:
		character_change_requested.emit(StringName())
		return
	character_change_requested.emit(internal_name)

func _on_hide_ui_texture_button_toggled(toggled_on: bool) -> void:
	for obj in _hideable_ui_objects:
		obj.visible = !toggled_on

func _on_close_button_pressed() -> void:
	close_requested.emit()
