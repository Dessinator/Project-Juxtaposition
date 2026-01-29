extends Control
class_name PlayableCharacterCharacterUI

const PLACEHOLDER_CHARACTER_NICKNAME: String = "Character Nickname"
const PLACEHOLDER_CHARACTER_NAME: String = "Character Name"
const PLACEHOLDER_CHARACTER_HALF_PRONOUNS: String = "they/them/theirs"
const PLACEHOLDER_CHARACTER_FULL_PRONOUNS: String = "they/them/their/theirs/themself"

const ATTK_STAT_INTERNAL_NAME: StringName = &"attack"
const DFNS_STAT_INTERNAL_NAME: StringName = &"defense"
const AGLT_STAT_INTERNAL_NAME: StringName = &"agility"
const VTLY_STAT_INTERNAL_NAME: StringName = &"vitality"

const ATK_DMG_SUBSTAT_INTERNAL_NAME: StringName = &"attack_damage"
const CRT_CHA_SUBSTAT_INTERNAL_NAME: StringName = &"critical_chance"
const CRT_MUL_SUBSTAT_INTERNAL_NAME: StringName = &"critical_multiplier"
const DMG_RES_SUBSTAT_INTERNAL_NAME: StringName = &"damage_resistance"
const DBF_RES_SUBSTAT_INTERNAL_NAME: StringName = &"debuff_resistance"
const BUF_RET_SUBSTAT_INTERNAL_NAME: StringName = &"buff_retention"
const MVT_SPD_SUBSTAT_INTERNAL_NAME: StringName = &"movement_speed"
const ATK_SPD_SUBSTAT_INTERNAL_NAME: StringName = &"attack_speed"
const SPS_RGN_SUBSTAT_INTERNAL_NAME: StringName = &"stamina_regeneration_rate"
const MAX_HPS_SUBSTAT_INTERNAL_NAME: StringName = &"maximum_health"
const HPS_RGN_SUBSTAT_INTERNAL_NAME: StringName = &"health_regeneration_rate"
const MAX_SPS_SUBSTAT_INTERNAL_NAME: StringName = &"maximum_stamina"

const LEVEL_1_EXPS_MATERIAL_VALUE: int = 1111
const LEVEL_2_EXPS_MATERIAL_VALUE: int = 3333
const LEVEL_3_EXPS_MATERIAL_VALUE: int = 9999
const LEVEL_4_EXPS_MATERIAL_VALUE: int = 22222

const CHARACTER_PICKER_ICON_BUTTON_SCENE: PackedScene = preload("res://nodes/render/ui-render-handler/buttons/character-picker-icon-button/character_picker_icon_button.tscn")
const CHARACTER_TALENT_SUBSECTION_PANEL_SCENE: PackedScene = preload("res://nodes/render/ui-render-handler/ui-visuals/talent-subsection-panel/talent_subsection_panel.tscn")

signal character_change_requested(internal_name: StringName)
signal close_requested

@onready var _character_picker_hbox_container: HBoxContainer = %CharacterPickerHBoxContainer

@onready var _character_info_tab_container: TabContainer = %CharacterInfoTabContainer

# character
@onready var _character_nickname_label: Label = %CharacterNicknameLabel
@onready var _character_half_pronouns_label: Label = %CharacterHalfPronounsLabel
@onready var _character_level_label: Label = %CharacterLevelLabel

# character stats & substats
@onready var _attk_character_stat_panel: CharacterStatPanel = %ATTKCharacterStatPanel
@onready var _dfns_character_stat_panel: CharacterStatPanel = %DFNSCharacterStatPanel
@onready var _aglt_character_stat_panel: CharacterStatPanel = %AGLTCharacterStatPanel
@onready var _vtly_character_stat_panel: CharacterStatPanel = %VTLYCharacterStatPanel

@onready var _character_short_description_label: Label = %CharacterShortDescriptionLabel

@onready var _character_advanced_level_label: Label = %CharacterAdvancedLevelLabel
@onready var _character_level_addend_hint_label: Label = %CharacterLevelAddendHintLabel
@onready var _character_required_exps_label: Label = %CharacterRequiredEXPsLabel
@onready var _character_exps_addend_hint_label: Label = %CharacterEXPsAddendHintLabel

@onready var _character_exps_status_bar: StatusBar = %CharacterEXPsStatusBar

@onready var _lv_1_exps_material_button: VariableAmountButton = %Lv1EXPsMaterialButton
@onready var _lv_2_exps_material_button: VariableAmountButton = %Lv2EXPsMaterialButton
@onready var _lv_3_exps_material_button: VariableAmountButton = %Lv3EXPsMaterialButton
@onready var _lv_4_exps_material_button: VariableAmountButton = %Lv4EXPsMaterialButton

# weapon

# talents
@onready var _talent_tab_container: TabContainer = %TalentTabContainer

@onready var _light_attack_talents_container: VBoxContainer = %LightAttackTalentsContainer
@onready var _heavy_attack_talents_container: VBoxContainer = %HeavyAttackTalentsContainer
@onready var _dodge_talents_container: VBoxContainer = %DodgeTalentsContainer
@onready var _parry_talents_container: VBoxContainer = %ParryTalentsContainer
@onready var _juxtaposition_talents_container: VBoxContainer = %JuxtapositionTalentsContainer

# friendship
@onready var _friendship_tab_container: TabContainer = %FriendshipTabContainer

@onready var _character_name_label: Label = %CharacterNameLabel
@onready var _character_full_pronouns_label: Label = %CharacterFullPronounsLabel

@onready var _character_gender_icon_texture_rect: TextureRect = %CharacterGenderIconTextureRect

@onready var _character_long_description_label: Label = %CharacterLongDescriptionLabel

# details
@onready var _character_stats_details_panel_container: PanelContainer = %CharacterStatsDetailsPanelContainer

@onready var _atkdmg_character_substat_panel: CharacterSubstatPanel = %ATKDMGCharacterSubstatPanel
@onready var _crtcha_character_substat_panel: CharacterSubstatPanel = %CRTCHACharacterSubstatPanel
@onready var _crtmul_character_substat_panel: CharacterSubstatPanel = %CRTMULCharacterSubstatPanel
@onready var _dmgres_character_substat_panel: CharacterSubstatPanel = %DMGRESCharacterSubstatPanel
@onready var _dbfres_character_substat_panel: CharacterSubstatPanel = %DBFRESCharacterSubstatPanel
@onready var _bufret_character_substat_panel: CharacterSubstatPanel = %BUFRETCharacterSubstatPanel
@onready var _mvtspd_character_substat_panel: CharacterSubstatPanel = %MVTSPDCharacterSubstatPanel
@onready var _atkspd_character_substat_panel: CharacterSubstatPanel = %ATKSPDCharacterSubstatPanel
@onready var _spsrgn_character_substat_panel: CharacterSubstatPanel = %SPSRGNCharacterSubstatPanel
@onready var _maxhps_character_substat_panel: CharacterSubstatPanel = %MAXHPSCharacterSubstatPanel
@onready var _hpsrgn_character_substat_panel: CharacterSubstatPanel = %HPSRGNCharacterSubstatPanel
@onready var _maxsps_character_substat_panel: CharacterSubstatPanel = %MAXSPSCharacterSubstatPanel

@onready var _weapon_stats_details_panel_container: PanelContainer = %WeaponStatsDetailsPanelContainer

var current_character_internal_name: StringName:
	set(value):
		current_character_internal_name = value

		# shouldn't ever happen but just in case
		if current_character_internal_name.is_empty():
			return
		
		var character_packet = Characters.get_character_packet(current_character_internal_name)
		_current_character = character_packet.character_scene.instantiate()
		
		_lv_1_exps_material_button.amount = 0
		_lv_2_exps_material_button.amount = 0
		_lv_3_exps_material_button.amount = 0
		_lv_4_exps_material_button.amount = 0

		_tentative_exps_addend = 0
		_tentative_level_addend = 0

		_update_all_character_data_fields()
		_update_all_character_stat_fields()

var _current_character: Character

var _character_picker_icon_buttons: Dictionary[StringName, Control]
var _character_talent_subsection_panels: Dictionary[StringName, Dictionary]

# should NOT be directly set!
var _tentative_level_addend: int:
	set(value):
		_tentative_level_addend = value

		_update_character_level_addend_hint_label()

var _tentative_exps_addend: int:
	set(value):
		_tentative_exps_addend = value

		_update_tentative_level_addend()

		_update_character_exps_addend_hint_label()
		_update_character_exps_status_bar_ghost_value()

@export var _hideable_ui_objects: Array[Control]

@export var nonbinary_gender_icon_texture: Texture2D
@export var male_gender_icon_texture: Texture2D
@export var female_gender_icon_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_fill_character_picker_icon_buttons()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _fill_character_picker_icon_buttons():
	for character_packet: CharacterPacket in Characters.get_all_character_packets():
		var character_data = character_packet.character_data
		var character_picker_icon_button_instance = CHARACTER_PICKER_ICON_BUTTON_SCENE.instantiate()

		_character_picker_icon_buttons[character_data.internal_name] = character_picker_icon_button_instance
		_character_picker_hbox_container.add_child(character_picker_icon_button_instance)

		var button = character_picker_icon_button_instance.get_node("%Button")
		button.text = character_data.internal_name
		button.pressed.connect(_on_character_picker_icon_button_pressed.bind(character_data.internal_name))
		

func add_character_picker_icon_button(character: Character):
	var internal_name = character.get_character_data().internal_name

	var instance = CHARACTER_PICKER_ICON_BUTTON_SCENE.instantiate()
	_character_picker_icon_buttons[internal_name] = instance
	_character_picker_hbox_container.add_child(instance)

	var button = instance.get_node("%Button")
	button.text = internal_name
	button.pressed.connect(_on_character_picker_icon_button_pressed.bind(character))

## updates all Controls that read CharacterData
func _update_all_character_data_fields():
	var data = _current_character.get_character_data()

	_set_character_nickname_label(data.nickname)
	_set_character_name_label(data.full_name)
	
	_set_character_half_pronouns_label(data.pronouns.get_half_string())
	_set_character_full_pronouns_label(data.pronouns.get_full_string())
	_set_character_gender_icon(data.gender)
	
	_update_character_level_label(data.experience_level)
	_update_character_advanced_level_label(data.experience_level, 100)
	_update_character_required_exps_label(data.experience_points, 9999)
	_update_character_exps_status_bar(data.experience_points, 9999)
	_update_character_exps_status_bar_ghost_value()
	
	_set_character_short_description_label(data.short_description)
	_set_character_long_description_label(data.long_description)

	_set_character_talent_container(_light_attack_talents_container, &"light_attack", data.light_attack_talents)
	_set_character_talent_container(_heavy_attack_talents_container, &"heavy_attack", data.heavy_attack_talents)
	_set_character_talent_container(_dodge_talents_container, &"dodge", data.dodge_talents)
	_set_character_talent_container(_parry_talents_container, &"parry", data.parry_talents)
	_set_character_talent_container(_juxtaposition_talents_container, &"juxtaposition", data.juxtaposition_talents)

## updates all Controls that read CharacterStats
func _update_all_character_stat_fields():
	var stats = _current_character.get_character_stats_copy()

	_update_character_stat_panel(_attk_character_stat_panel, stats.get_stat(ATTK_STAT_INTERNAL_NAME))
	_update_character_stat_panel(_dfns_character_stat_panel, stats.get_stat(DFNS_STAT_INTERNAL_NAME))
	_update_character_stat_panel(_aglt_character_stat_panel, stats.get_stat(AGLT_STAT_INTERNAL_NAME))
	_update_character_stat_panel(_vtly_character_stat_panel, stats.get_stat(VTLY_STAT_INTERNAL_NAME))

	_update_character_substat_panel(_atkdmg_character_substat_panel, stats.get_substat(ATK_DMG_SUBSTAT_INTERNAL_NAME), stats.get_stat(ATTK_STAT_INTERNAL_NAME))
	_update_character_substat_panel(_crtcha_character_substat_panel, stats.get_substat(CRT_CHA_SUBSTAT_INTERNAL_NAME), stats.get_stat(ATTK_STAT_INTERNAL_NAME))
	_update_character_substat_panel(_crtmul_character_substat_panel, stats.get_substat(CRT_MUL_SUBSTAT_INTERNAL_NAME), stats.get_stat(ATTK_STAT_INTERNAL_NAME))
	_update_character_substat_panel(_dmgres_character_substat_panel, stats.get_substat(DMG_RES_SUBSTAT_INTERNAL_NAME), stats.get_stat(DFNS_STAT_INTERNAL_NAME))
	_update_character_substat_panel(_dbfres_character_substat_panel, stats.get_substat(DBF_RES_SUBSTAT_INTERNAL_NAME), stats.get_stat(DFNS_STAT_INTERNAL_NAME))
	_update_character_substat_panel(_bufret_character_substat_panel, stats.get_substat(BUF_RET_SUBSTAT_INTERNAL_NAME), stats.get_stat(DFNS_STAT_INTERNAL_NAME))
	_update_character_substat_panel(_mvtspd_character_substat_panel, stats.get_substat(MVT_SPD_SUBSTAT_INTERNAL_NAME), stats.get_stat(AGLT_STAT_INTERNAL_NAME))
	_update_character_substat_panel(_atkspd_character_substat_panel, stats.get_substat(ATK_SPD_SUBSTAT_INTERNAL_NAME), stats.get_stat(AGLT_STAT_INTERNAL_NAME))
	_update_character_substat_panel(_spsrgn_character_substat_panel, stats.get_substat(SPS_RGN_SUBSTAT_INTERNAL_NAME), stats.get_stat(AGLT_STAT_INTERNAL_NAME))
	_update_character_substat_panel(_maxhps_character_substat_panel, stats.get_substat(MAX_HPS_SUBSTAT_INTERNAL_NAME), stats.get_stat(VTLY_STAT_INTERNAL_NAME))
	_update_character_substat_panel(_hpsrgn_character_substat_panel, stats.get_substat(HPS_RGN_SUBSTAT_INTERNAL_NAME), stats.get_stat(VTLY_STAT_INTERNAL_NAME))
	_update_character_substat_panel(_maxsps_character_substat_panel, stats.get_substat(MAX_SPS_SUBSTAT_INTERNAL_NAME), stats.get_stat(VTLY_STAT_INTERNAL_NAME))

func _update_tentative_level_addend():
	var data = _current_character.get_character_data()
	var current_exps = data.experience_points
	var tentative_level_addend = 0
	var current_level_sum = current_exps + _tentative_exps_addend
	if current_level_sum > 9999:
		current_level_sum = 9999
	var remaining_tentative_exp = _tentative_exps_addend - current_level_sum

	# placeholder exps cap is 9999.
	if current_level_sum >= 9999:
		tentative_level_addend += 1

	tentative_level_addend += int(remaining_tentative_exp / 9999)
	_tentative_level_addend = tentative_level_addend

# labels

func _set_character_nickname_label(character_nickname: String):
	if character_nickname.is_empty():
		character_nickname = PLACEHOLDER_CHARACTER_NICKNAME
	
	_character_nickname_label.text = "\"{character_nickname}\"".format({"character_nickname" : character_nickname})
func _set_character_name_label(character_name: String):
	if character_name.is_empty():
		character_name = PLACEHOLDER_CHARACTER_NAME
	
	_character_name_label.text = "{character_name}".format({"character_name" : character_name})

func _set_character_half_pronouns_label(character_pronouns: String):
	if character_pronouns.is_empty():
		character_pronouns = PLACEHOLDER_CHARACTER_HALF_PRONOUNS
	
	var string = "({character_pronouns})".format({"character_pronouns" : character_pronouns})
	_character_half_pronouns_label.text = string
func _set_character_full_pronouns_label(character_pronouns: String):
	if character_pronouns.is_empty():
		character_pronouns = PLACEHOLDER_CHARACTER_FULL_PRONOUNS
	
	var string = "({character_pronouns})".format({"character_pronouns" : character_pronouns})
	_character_full_pronouns_label.text = string

func _update_character_level_label(character_level: int):
	_character_level_label.text = "Lv. {character_level}".format({"character_level" : str(character_level)})
func _update_character_advanced_level_label(character_level: int, character_max_level: int):
	_character_advanced_level_label.text = "Level {character_level}/{character_max_level}".format({
		"character_level" : str(character_level),
		"character_max_level" : str(character_max_level)
	})
func _update_character_required_exps_label(character_experience_points: int, character_max_experience_points: int):
	_character_required_exps_label.text = "(EXPs: {character_experience_points}/{character_max_experience_points})".format({
		"character_experience_points" : str(character_experience_points),
		"character_max_experience_points" : str(character_max_experience_points)
	})

func _update_character_level_addend_hint_label():
	if not _character_level_addend_hint_label:
			return
	
	if _tentative_level_addend == 0:
		_character_level_addend_hint_label.text = ""
		_character_level_addend_hint_label.visible = false
		return
	
	_character_level_addend_hint_label.visible = true
	_character_level_addend_hint_label.text = "+{tentative_level_addend}".format({ "tentative_level_addend" : str(_tentative_level_addend) })
func _update_character_exps_addend_hint_label():
	if not _character_exps_addend_hint_label:
			return
		
	if _tentative_exps_addend == 0:
		_character_exps_addend_hint_label.text = ""
		_character_exps_addend_hint_label.visible = false
		return
	
	_character_exps_addend_hint_label.visible = true
	_character_exps_addend_hint_label.text = "(+{tentative_exps_addend})".format({ "tentative_exps_addend" : str(_tentative_exps_addend) })

func _set_character_short_description_label(short_description: String):
	_character_short_description_label.text = short_description
func _set_character_long_description_label(long_description: String):
	_character_long_description_label.text = long_description

# icons

func _set_character_gender_icon(character_gender: CharacterData.CharacterGender):
	match character_gender:
		CharacterData.CharacterGender.GENDER_NONBINARY:
			_character_gender_icon_texture_rect.texture = nonbinary_gender_icon_texture
		CharacterData.CharacterGender.GENDER_MALE:
			_character_gender_icon_texture_rect.texture = male_gender_icon_texture
		CharacterData.CharacterGender.GENDER_FEMALE:
			_character_gender_icon_texture_rect.texture = female_gender_icon_texture

# progress bars

func _update_character_exps_status_bar(character_experience_points: int, character_max_experience_points: int):
	_character_exps_status_bar.set_current_value(character_experience_points)
	_character_exps_status_bar.set_max_value(character_max_experience_points)

func _update_character_exps_status_bar_ghost_value():
	var data = _current_character.get_character_data()

	_character_exps_status_bar.set_ghost_value(data.experience_points + _tentative_exps_addend)

# panels

func _update_character_stat_panel(character_stat_panel: CharacterStatPanel, stat: Stat):
	character_stat_panel.stat_value = stat.get_value(true)
	character_stat_panel.stat_modifier_value = stat.get_constant()

func _update_character_substat_panel(character_substat_panel: CharacterSubstatPanel, substat: Substat, source_stat: Stat):
	character_substat_panel.substat_abbreviation = substat.get_readable_abbreviation()
	character_substat_panel.substat_name = substat.get_readable_name()
	character_substat_panel.source_stat_abbreviation = source_stat.get_readable_abbreviation()
	character_substat_panel.source_stat_value = source_stat.get_value(false)
	character_substat_panel.modifier_value = substat.get_constant()
	character_substat_panel.description = substat.get_description()
	character_substat_panel.substat_curve = substat.get_curve()
	character_substat_panel.value = substat.sample(source_stat.get_value(false), false)

func _set_character_talent_container(container: Control, type: StringName, talents: Array[CharacterTalent]):
	if _character_talent_subsection_panels.has(type):
		_character_talent_subsection_panels.erase(type)

	for child in container.get_children():
		child.queue_free()
	
	for talent in talents:
		var talent_subsection_panel_instance: CharacterTalentSubsectionPanel = CHARACTER_TALENT_SUBSECTION_PANEL_SCENE.instantiate()
		if not _character_talent_subsection_panels.has(type): 
			_character_talent_subsection_panels[type] = {talent.internal_name : talent_subsection_panel_instance}
		else:
			_character_talent_subsection_panels[type][talent.internal_name] = talent_subsection_panel_instance
		container.add_child(talent_subsection_panel_instance)
		
		talent_subsection_panel_instance.talent_title = talent.title
		talent_subsection_panel_instance.talent_simple_description = talent.simple_description
		talent_subsection_panel_instance.talent_long_description = talent.long_description
		talent_subsection_panel_instance.talent_level = talent.level

# buttons

func _on_close_button_pressed() -> void:
	close_requested.emit()

func _on_character_picker_icon_button_pressed(internal_name: StringName):
	character_change_requested.emit(internal_name)

func _on_character_level_button_pressed() -> void:
	_character_info_tab_container.current_tab = 0
func _on_weapon_level_button_pressed() -> void:
	_character_info_tab_container.current_tab = 1
func _on_talents_button_pressed() -> void:
	_character_info_tab_container.current_tab = 2
func _on_friendship_button_pressed() -> void:
	_character_info_tab_container.current_tab = 3

func _on_lv_1_exps_material_button_amount_cleared(old: int) -> void:
	_tentative_exps_addend -= (old * LEVEL_1_EXPS_MATERIAL_VALUE)
func _on_lv_2_exps_material_button_amount_cleared(old: int) -> void:
	_tentative_exps_addend -= (old * LEVEL_2_EXPS_MATERIAL_VALUE)
func _on_lv_3_exps_material_button_amount_cleared(old: int) -> void:
	_tentative_exps_addend -= (old * LEVEL_3_EXPS_MATERIAL_VALUE)
func _on_lv_4_exps_material_button_amount_cleared(old: int) -> void:
	_tentative_exps_addend -= (old * LEVEL_4_EXPS_MATERIAL_VALUE)

func _on_lv_1_exps_material_button_amount_decreased(old: int, new: int) -> void:
	_tentative_exps_addend -= (old - new) * LEVEL_1_EXPS_MATERIAL_VALUE
func _on_lv_2_exps_material_button_amount_decreased(old: int, new: int) -> void:
	_tentative_exps_addend -= (old - new) * LEVEL_2_EXPS_MATERIAL_VALUE
func _on_lv_3_exps_material_button_amount_decreased(old: int, new: int) -> void:
	_tentative_exps_addend -= (old - new) * LEVEL_3_EXPS_MATERIAL_VALUE
func _on_lv_4_exps_material_button_amount_decreased(old: int, new: int) -> void:
	_tentative_exps_addend -= (old - new) * LEVEL_4_EXPS_MATERIAL_VALUE

func _on_lv_1_exps_material_button_amount_increased(old: int, new: int) -> void:
	_tentative_exps_addend += (new - old) * LEVEL_1_EXPS_MATERIAL_VALUE
func _on_lv_2_exps_material_button_amount_increased(old: int, new: int) -> void:
	_tentative_exps_addend += (new - old) * LEVEL_2_EXPS_MATERIAL_VALUE
func _on_lv_3_exps_material_button_amount_increased(old: int, new: int) -> void:
	_tentative_exps_addend += (new - old) * LEVEL_3_EXPS_MATERIAL_VALUE
func _on_lv_4_exps_material_button_amount_increased(old: int, new: int) -> void:
	_tentative_exps_addend += (new - old) * LEVEL_4_EXPS_MATERIAL_VALUE

func _on_character_auto_add_exps_button_pressed() -> void:
	pass # Replace with function body.
func _on_character_add_exps_button_pressed() -> void:
	var data = _current_character.get_character_data()

	data.add_experience_points(_tentative_exps_addend)

	_update_character_level_label(data.experience_level)
	_update_character_advanced_level_label(data.experience_level, 100)
	_update_character_required_exps_label(data.experience_points, 9999)
	_update_character_exps_status_bar(data.experience_points, 9999)

	_lv_1_exps_material_button.amount = 0
	_lv_2_exps_material_button.amount = 0
	_lv_3_exps_material_button.amount = 0
	_lv_4_exps_material_button.amount = 0

	_tentative_exps_addend = 0
	_tentative_level_addend = 0

	_update_character_exps_status_bar_ghost_value()

func _on_talents_light_attack_button_pressed() -> void:
	_talent_tab_container.current_tab = 0
func _on_talents_heavy_attack_button_pressed() -> void:
	_talent_tab_container.current_tab = 1
func _on_talents_dodge_button_pressed() -> void:
	_talent_tab_container.current_tab = 2
func _on_talents_parry_button_pressed() -> void:
	_talent_tab_container.current_tab = 3
func _on_talents_juxtaposition_button_pressed() -> void:
	_talent_tab_container.current_tab = 4

func _on_friendship_info_button_pressed() -> void:
	_friendship_tab_container.current_tab = 0
func _on_friendship_facts_button_pressed() -> void:
	_friendship_tab_container.current_tab = 1
func _on_friendship_voice_lines_button_pressed() -> void:
	_friendship_tab_container.current_tab = 2

func _on_character_stat_details_button_pressed() -> void:
	_character_stats_details_panel_container.visible = true
func _on_character_stats_details_close_button_pressed() -> void:
	_character_stats_details_panel_container.visible = false
func _on_weapon_stat_details_button_pressed() -> void:
	_weapon_stats_details_panel_container.visible = true
func _on_weapon_stats_details_close_button_pressed() -> void:
	_weapon_stats_details_panel_container.visible = false

func _on_hide_ui_texture_button_toggled(toggled_on: bool) -> void:
	for obj in _hideable_ui_objects:
		obj.visible = !toggled_on
