@tool
class_name CharacterActionVisual
extends PanelContainer

const EMPTY_ACTION_NAME_PLACEHOLDER: String = "Action Name"

@export var _action_name: String:
	set(value):
		_action_name = value
		if _action_name.is_empty():
			%Button.text = EMPTY_ACTION_NAME_PLACEHOLDER
			return
		
		%Button.text = _action_name

@onready var _button: Button = %Button
@onready var _cooldown_progress_bar: ProgressBar = %CooldownProgressBar
