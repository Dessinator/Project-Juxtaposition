@tool
class_name GraphNodeHorizontalOptionContainer
extends HBoxContainer

signal input_set()

const PLACEHOLDER_LABEL_TEXT: String = "<Option Name>:"

@onready var label: Label = %Label

@onready var int_input: SpinBox = %IntInput
@onready var float_input: SpinBox = %FloatInput
@onready var string_input: LineEdit = %StringInput
@onready var boolean_input: CheckBox = %BooleanInput
@onready var option_input: OptionButton = %OptionInput

@onready var string_name_input_container: HBoxContainer = %StringNameInputContainer
@onready var string_name_input: LineEdit = %StringNameInput

enum InputType
{
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_STRING,
	TYPE_STRINGNAME,
	TYPE_BOOLEAN,
	TYPE_OPTION
}

@export var _label_text: String:
	set(value):
		_label_text = value
		_update_label_text()

@export var _input_type: InputType = InputType.TYPE_INT:
	set(value):
		_input_type = value
		_update_input_type()

@export var _options: Array[String]:
	set(value):
		_options = value
		_update_options()

func _ready() -> void:
	if Engine.is_editor_hint():
		_update_label_text()
		_update_input_type()
		_update_options()

func _update_label_text():
	if _label_text.is_empty():
		%Label.text = PLACEHOLDER_LABEL_TEXT
		return
	
	%Label.text = "{label_text}:".format({"label_text" : _label_text})

func _update_input_type():
	match _input_type:
			InputType.TYPE_INT:
				%IntInput.visible = true
				%FloatInput.visible = false
				%StringInput.visible = false
				%BooleanInput.visible = false
				%StringNameInputContainer.visible = false
				%OptionInput.visible = false
			InputType.TYPE_FLOAT:
				%IntInput.visible = false
				%FloatInput.visible = true
				%StringInput.visible = false
				%BooleanInput.visible = false
				%StringNameInputContainer.visible = false
				%OptionInput.visible = false
			InputType.TYPE_STRING:
				%IntInput.visible = false
				%FloatInput.visible = false
				%StringInput.visible = true
				%BooleanInput.visible = false
				%StringNameInputContainer.visible = false
				%OptionInput.visible = false
			InputType.TYPE_STRINGNAME:
				%IntInput.visible = false
				%FloatInput.visible = false
				%StringInput.visible = false
				%BooleanInput.visible = false
				%StringNameInputContainer.visible = true
				%OptionInput.visible = false
			InputType.TYPE_BOOLEAN:
				%IntInput.visible = false
				%FloatInput.visible = false
				%StringInput.visible = false
				%BooleanInput.visible = true
				%StringNameInputContainer.visible = false
				%OptionInput.visible = false
			InputType.TYPE_OPTION:
				%IntInput.visible = false
				%FloatInput.visible = false
				%StringInput.visible = false
				%BooleanInput.visible = false
				%StringNameInputContainer.visible = false
				%OptionInput.visible = true

func _update_options():
	%OptionInput.clear()
	
	for option in _options:
		%OptionInput.add_item(option)
	
	if %OptionInput.item_count == 0:
		return
	%OptionInput.select(0)
	
	if not _input_type == InputType.TYPE_OPTION:
		return

func set_input_type(input_type: InputType):
	_input_type = input_type
func set_value(value: Variant):
	match _input_type:
			InputType.TYPE_INT:
				%IntInput.value = value
			InputType.TYPE_FLOAT:
				%FloatInput.value = value
			InputType.TYPE_STRING:
				%StringInput.text = value
			InputType.TYPE_STRINGNAME:
				%StringNameInput.text = str(value)
			InputType.TYPE_BOOLEAN:
				%BooleanInput.button_pressed = value
			InputType.TYPE_OPTION:
				%OptionInput.selected = value

func read() -> Variant:
	match _input_type:
			InputType.TYPE_INT:
				return %IntInput.value
			InputType.TYPE_FLOAT:
				return %FloatInput.value
			InputType.TYPE_STRING:
				return %StringInput.text
			InputType.TYPE_STRINGNAME:
				return StringName(%StringNameInput.text)
			InputType.TYPE_BOOLEAN:
				return %BooleanInput.button_pressed
			InputType.TYPE_OPTION:
				return %OptionInput.selected
			_:
				return null

func _on_int_input_value_changed(value: float) -> void:
	input_set.emit()
func _on_float_input_value_changed(value: float) -> void:
	input_set.emit()
func _on_string_input_text_changed(new_text: String) -> void:
	input_set.emit()
func _on_string_name_input_text_changed(new_text: String) -> void:
	input_set.emit()
func _on_boolean_input_toggled(toggled_on: bool) -> void:
	input_set.emit()
func _on_option_input_item_selected(index: int) -> void:
	input_set.emit()
