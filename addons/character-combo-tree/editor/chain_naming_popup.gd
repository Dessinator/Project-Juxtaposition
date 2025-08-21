@tool
class_name ChainNamingPopup
extends Window

const CHAIN_PLACEHOLDER_NAME: StringName = &'New Chain'

signal named(chain_name: String)

@onready var _line_edit: LineEdit = %LineEdit
@onready var _ok_button: Button = %OKButton
@onready var _cancel_button: Button = %CancelButton

func _ready():
	_line_edit.grab_focus()

func _on_cancel_button_pressed() -> void:
	named.emit("")
	queue_free()

func _on_ok_button_pressed() -> void:
	if _line_edit.text.is_empty():
		named.emit(CHAIN_PLACEHOLDER_NAME)
	named.emit(_line_edit.text)
	queue_free()

func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text.is_empty():
		named.emit(CHAIN_PLACEHOLDER_NAME)
	named.emit(_line_edit.text)
	queue_free()
