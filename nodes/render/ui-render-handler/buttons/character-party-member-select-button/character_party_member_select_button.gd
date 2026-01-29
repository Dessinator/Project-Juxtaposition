class_name CharacterPartyMemberSelectButton
extends PanelContainer

@onready var _character_portrait_texture_rect: TextureRect = %CharacterPortraitTextureRect
@onready var _character_nickname_label: Label = %CharacterNicknameLabel
@onready var _character_level_label: Label = %CharacterLevelLabel

@onready var _member_index_panel_container: PanelContainer = %MemberIndexPanelContainer
@onready var _member_index_label: Label = %MemberIndexLabel

@onready var button: Button = %Button

var character_portrait: Texture2D:
	set(value):
		character_portrait = value

		if character_portrait == null:
			return

		_character_portrait_texture_rect.texture = character_portrait

var character_nickname: String:
	set(value):
		character_nickname = value

		_character_nickname_label.text = "\"{nickname}\"".format({ "nickname" : character_nickname })

var character_level: int:
	set(value):
		character_level = value

		_character_level_label.text = "Lv: " + str(character_level)

var show_member_index: bool:
	set(value):
		show_member_index = value

		_member_index_panel_container.visible = show_member_index

var member_index: int:
	set(value):
		member_index = value

		_member_index_label.text = str(member_index)