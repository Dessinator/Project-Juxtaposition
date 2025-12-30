@tool
class_name VoiceLinePanel
extends PanelContainer

const PLACEHOLDER_TITLE_TEXT: String = "Voice Line Title"

@onready var _voice_line_audio_stream_player: AudioStreamPlayer = %VoiceLineAudioStreamPlayer

@onready var _title_label: Label = %TitleLabel

@export var title: String:
	set(value):
		title = value

		if %TitleLabel == null:
			return
		
		if title.is_empty():
			%TitleLabel.text = PLACEHOLDER_TITLE_TEXT
			return
		
		%TitleLabel.text = title

@export var voice_line: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
