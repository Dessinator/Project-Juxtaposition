@tool
class_name CharacterStatPanel
extends PanelContainer

const PLACEHOLDER_STAT_NAME: String = "STAT"

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _stat_name_label: Label = %StatNameLabel
@onready var _stat_value_label: Label = %StatValueLabel
@onready var _stat_modifier_value_label: Label = %StatModifierValueLabel

@export var icon: Texture2D:
	set(value):
		icon = value
		%TextureRect.texture = icon
@export var stat_name: String:
	set(value):
		stat_name = value
		
		if not %StatNameLabel:
			return

		if stat_name.is_empty():
			%StatNameLabel.text = PLACEHOLDER_STAT_NAME + ":"
			return
		
		%StatNameLabel.text = stat_name + ":"
@export var stat_value: int:
	set(value):
		stat_value = value
		
		if not %StatValueLabel:
			return
		
		%StatValueLabel.text = str(stat_value)
@export var stat_modifier_value: int:
	set(value):
		stat_modifier_value = value

		if not %StatModifierValueLabel:
			return
		
		if stat_modifier_value == 0:
			%StatModifierValueLabel.text = ""
		elif stat_modifier_value > 0:
			%StatModifierValueLabel.text = "+" + str(stat_modifier_value)
		elif stat_modifier_value < 0:
			%StatModifierValueLabel.text = str(stat_modifier_value)
