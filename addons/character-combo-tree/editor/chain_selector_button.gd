@tool
class_name ChainSelectorButton
extends PanelContainer

const CHAIN_PLACEHOLDER_NAME: StringName = &'New Chain'

signal right_clicked
signal clicked

@onready var button: Button = %Button

@export var chain_name: String:
	set(value):
		chain_name = value
		if chain_name.is_empty():
			%Button.text = CHAIN_PLACEHOLDER_NAME
			return
		%Button.text = chain_name

func _ready():
	button.pressed.connect(_emit_clicked)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			right_clicked.emit()

func _emit_clicked():
	clicked.emit()
