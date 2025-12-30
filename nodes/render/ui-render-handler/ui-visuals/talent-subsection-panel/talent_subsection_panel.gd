@tool
class_name CharacterTalentSubsectionPanel
extends PanelContainer

const PLACEHOLDER_NAME_TEXT: String = "Talent Name"
const PLACEHOLDER_LEVEL_TEXT: String = "Lv. ???"
const PLACEHOLDER_DESCRIPTION_TEXT: String = ""

@onready var _name_label: Label = %NameLabel
@onready var _level_label: Label = %LevelLabel
@onready var _description_label: Label = %DescriptionLabel

var _use_simple_description: bool = false:
	set(value):
		_use_simple_description = value

		if %DescriptionLabel == null:
			return

		if _use_simple_description:
			%DescriptionLabel.text = talent_simple_description
			return
		
		%DescriptionLabel.text = talent_long_description 

@export var talent_title: String:
	set(value):
		talent_title = value

		if %NameLabel == null:
			return

		if talent_title.is_empty():
			%NameLabel.text = PLACEHOLDER_NAME_TEXT
			return
		
		%NameLabel.text = talent_title 
@export var talent_level: int = -1:
	set(value):
		talent_level = value

		if %LevelLabel == null:
			return

		if talent_level < 0:
			%LevelLabel.text = PLACEHOLDER_LEVEL_TEXT
			return
		
		%LevelLabel.text = "Lv. {talent_level}".format({"talent_level" : str(talent_level)})
@export_multiline var talent_long_description: String:
	set(value):
		talent_long_description = value
		
		if %DescriptionLabel == null:
			return

		if _use_simple_description:
			return

		%DescriptionLabel.text = talent_long_description 
@export_multiline var talent_simple_description: String:
	set(value):
		talent_simple_description = value

		if %DescriptionLabel == null:
			return

		if not _use_simple_description:
			return

		%DescriptionLabel.text = talent_simple_description


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_simplify_description_check_button_toggled(toggled_on: bool) -> void:
	_use_simple_description = toggled_on
