@tool
class_name CharacterActionVisual
extends PanelContainer

const EMPTY_ACTION_NAME_PLACEHOLDER: String = "Action Name"

enum DurationMode
{
	MODE_NONE,
	MODE_AVAILABLE,
	MODE_UNAVAILABLE
}

@onready var _button: Button = %Button
@onready var _cooldown_progress_bar: TextureProgressBar = %CooldownProgressBar
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _cooldown_timer: Timer = %CooldownTimer

var _duration_mode = DurationMode.MODE_NONE

@export var _action_name: String:
	set(value):
		_action_name = value
		if _action_name.is_empty():
			%Button.text = EMPTY_ACTION_NAME_PLACEHOLDER
			return
		
		%Button.text = _action_name
@export var _action_icon: TextureRect
@export var action_visual_type: PlayableCharacterGameplayState.PlayableCharacterActionType = PlayableCharacterGameplayState.PlayableCharacterActionType.TYPE_OTHER 

func _process(delta: float) -> void:
	_handle_duration()

func press():
	_button.pressed.emit()
func hold():
	_animation_player.play("holding")
func release():
	if DurationMode.MODE_AVAILABLE:
		_cooldown_progress_bar.value = _cooldown_progress_bar.max_value
	if DurationMode.MODE_UNAVAILABLE:
		_cooldown_progress_bar.value = 0
	
	_duration_mode = DurationMode.MODE_NONE
	_animation_player.play("pressed")

func set_available():
	_cooldown_progress_bar.value = 0
func set_unavailable():
	_cooldown_progress_bar.value = _cooldown_progress_bar.max_value

func set_available_duration(duration_seconds: float):
	_cooldown_timer.start(duration_seconds)
	_cooldown_progress_bar.max_value = duration_seconds
	_cooldown_progress_bar.value = 0
	_duration_mode = DurationMode.MODE_AVAILABLE
func set_unavailable_duration(duration_seconds: float):
	_cooldown_timer.start(duration_seconds)
	_cooldown_progress_bar.max_value = duration_seconds
	_cooldown_progress_bar.value = _cooldown_progress_bar.max_value
	_duration_mode = DurationMode.MODE_UNAVAILABLE

func _handle_duration():
	match _duration_mode:
		DurationMode.MODE_NONE:
			return
		DurationMode.MODE_AVAILABLE:
			_cooldown_progress_bar.value = _cooldown_timer.wait_time - _cooldown_timer.time_left
		DurationMode.MODE_UNAVAILABLE:
			_cooldown_progress_bar.value = _cooldown_timer.time_left

func _on_cooldown_timer_timeout() -> void:
	# fix error where progress bar doesnt visually show full or empty.
	if DurationMode.MODE_AVAILABLE:
		_cooldown_progress_bar.value = _cooldown_progress_bar.max_value
	if DurationMode.MODE_UNAVAILABLE:
		_cooldown_progress_bar.value = 0
	
	_duration_mode = DurationMode.MODE_NONE
