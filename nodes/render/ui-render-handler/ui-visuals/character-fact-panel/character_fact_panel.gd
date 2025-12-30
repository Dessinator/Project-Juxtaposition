@tool
class_name CharacterFactPanel
extends PanelContainer

const PLACEHOLDER_TITLE_TEXT: String = "Fact Title"
const PLACEHOLDER_LOCKED_DESCRIPTION_TEXT: String = "Placeholder fact unlock criteria hint"

@onready var _voice_line_audio_stream_player: AudioStreamPlayer = %VoiceLineAudioStreamPlayer

@onready var _title_label: Label = %TitleLabel
@onready var _locked_title_label: Label = %LockedTitleLabel

@onready var _description_panel_container: PanelContainer = %DescriptionPanelContainer
@onready var _locked_description_label: Label = %LockedDescriptionLabel
@onready var _description_label: Label = %DescriptionLabel

@export var title: String:
	set(value):
		title = value

		if %TitleLabel == null:
			return
		
		if title.is_empty():
			%TitleLabel.text = PLACEHOLDER_TITLE_TEXT
			return
		
		%TitleLabel.text = title

@export var locked_description: String:
	set(value):
		locked_description = value

		if %LockedDescriptionLabel == null:
			return
		
		if locked_description.is_empty():
			%LockedDescriptionLabel.text = PLACEHOLDER_LOCKED_DESCRIPTION_TEXT
			return
		
		%LockedDescriptionLabel.text = locked_description
@export var description: String:
	set(value):
		description = value

		if %DescriptionLabel == null:
			return
		
		%DescriptionLabel.text = description

@export var voice_line: AudioStream

@export var is_locked: bool:
	set(value):
		is_locked = value

		if is_locked:
			_locked_title_label.visible = true

			_locked_description_label.visible = true
			_description_label.visible = false
			return
		
		_locked_title_label.visible = false

		_locked_description_label.visible = false
		_description_label.visible = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_expand_button_toggled(toggled_on: bool) -> void:
	_description_panel_container.visible = toggled_on
