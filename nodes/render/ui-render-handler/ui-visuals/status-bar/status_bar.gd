@tool
class_name StatusBar
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
			%GhostValueTextureProgressBar.texture_under = PlaceholderTexture2D.new()
			return
		%GhostValueTextureProgressBar.texture_under = _under
@export var _over: Texture2D:
	set(value):
		_over = value
		if not _over:
			%TrueValueTextureProgressBar.texture_over = null
			return
		%TrueValueTextureProgressBar.texture_over = _over
@export var _ghost_progress: Texture2D:
	set(value):
		_ghost_progress = value
		if not _ghost_progress:
			%GhostValueTextureProgressBar.texture_progress = PlaceholderTexture2D.new()
			return
		%GhostValueTextureProgressBar.texture_progress = _ghost_progress
@export var _true_progress: Texture2D:
	set(value):
		_true_progress = value
		if not _true_progress:
			%TrueValueTextureProgressBar.texture_progress = PlaceholderTexture2D.new()
			return
		%TrueValueTextureProgressBar.texture_progress = _true_progress

var _current_value: int:
	set(value):
		_current_value = clampi(value, 0, _max_value)
		if %TrueValueTextureProgressBar:
			%TrueValueTextureProgressBar.value = _current_value
		
		if %Label:
			%Label.text = "{label}: {current_value}".format({"label": _label, "current_value": _current_value})
var _ghost_value: int:
	set(value):
		_ghost_value = clampi(value, _current_value, _max_value)
		if %GhostValueTextureProgressBar: 
			%GhostValueTextureProgressBar.value = _ghost_value
var _max_value: int:
	set(value):
		if value < 0:
			_max_value = 0
		else:
			_max_value = value
		_current_value = clampi(_current_value, 0, _max_value)
		_ghost_value = clampi(_ghost_value, _current_value, _max_value)
		if %TrueValueTextureProgressBar:
			%TrueValueTextureProgressBar.max_value = _max_value
		if %GhostValueTextureProgressBar: 
			%GhostValueTextureProgressBar.max_value = _max_value

@onready var _ghost_value_texture_progress_bar: TextureProgressBar = %GhostValueTextureProgressBar
@onready var _status_texture_progress_bar: TextureProgressBar = %TrueValueTextureProgressBar
@onready var _status_label: Label = %Label
@onready var _update_ghost_progress_delay_timer: Timer = %UpdateGhostProgressDelayTimer

var _is_updating_ghost_value: bool = false

func _ready():
	_status_label.text = "{label}: {current_value}".format({"label": _label, "current_value": _current_value})

func _process(delta: float) -> void:
	_handle_update_ghost_value(delta)

func set_current_value(value: int):
	var old = _current_value
	_current_value = value
	
	if old <= _current_value:
		return
	
	if %UpdateGhostProgressDelayTimer.is_stopped():
		_ghost_value = old
	
	%UpdateGhostProgressDelayTimer.start()
	_is_updating_ghost_value = false

func set_max_value(value: int):
	_max_value = value

func _handle_update_ghost_value(delta: float):
	if not _is_updating_ghost_value:
		return
	
	if _ghost_value <= _current_value:
		return
	
	_ghost_value = lerp(_ghost_value, _current_value, delta)


func _on_update_ghost_progress_delay_timer_timeout() -> void:
	_is_updating_ghost_value = true
