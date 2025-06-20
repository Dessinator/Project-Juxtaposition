@tool
class_name CharacterStatusBar
extends PanelContainer

const PLACEHOLDER_STATUS_LABEL: String = "PTS"

@export var _show_status_label: bool = true:
	set(value):
		_show_status_label = value
		%Label.visible = _show_status_label
@export var _label: String:
	set(value):
		_label = value
		if _label.is_empty():
			_label = PLACEHOLDER_STATUS_LABEL
		if %Label:
			%Label.text = "{label}: {current_value}".format({"label": _label, "current_value": _current_value})

@export_category("Progress Bar Appearance")
@export var _under: Texture2D:
	set(value):
		_under = value
		if not _under:
			%TextureProgressBar.texture_under = PlaceholderTexture2D.new()
			return
		%TextureProgressBar.texture_under = _under
@export var _over: Texture2D:
	set(value):
		_over = value
		if not _over:
			%TextureProgressBar.texture_over = null
			return
		%TextureProgressBar.texture_over = _over
@export var _progress: Texture2D:
	set(value):
		_progress = value
		if not _progress:
			%TextureProgressBar.texture_progress = PlaceholderTexture2D.new()
			return
		%TextureProgressBar.texture_progress = _progress

var _current_value: int:
	set(value):
		_current_value = value
		_current_value = clampf(_current_value, 0, _max_value)
		if %TextureProgressBar:
			%TextureProgressBar.value = _current_value
		
		if %Label:
			%Label.text = "{label}: {current_value}".format({"label": _label, "current_value": _current_value})
var _max_value: int:
	set(value):
		_max_value = value
		if _max_value < 0:
			_max_value = 0
		_current_value = clampf(_current_value, 0, _max_value)
		if %TextureProgressBar:
			%TextureProgressBar.max_value = _max_value

@onready var _status_texture_progress_bar: TextureProgressBar = %TextureProgressBar
@onready var _status_label: Label = %Label

func _ready():
	_status_label.text = "{label}: {current_value}".format({"label": _label, "current_value": _current_value})

func set_current_value(value: int):
	_current_value = value
func set_max_value(value: int):
	_max_value = value
