@tool
class_name VariableAmountButton
extends Control

const PLACEHOLDER_BUTTON_TEXT: String = "Item Name"
const INCREASED_INCREMENT: int = 5

signal amount_changed(amount: int)
signal amount_increased(old: int, new: int)
signal amount_decreased(old: int, new: int)
signal amount_cleared(old: int)

@onready var _item_button: Button = %ItemButton
@onready var _remove_all_button: Button = %RemoveAllButton
@onready var _amount_panel_container: PanelContainer = %AmountPanelContainer
@onready var _amount_label: Label = %AmountLabel

@onready var _hold_timer: Timer = %HoldTimer
@onready var _increase_increment_timer: Timer = %IncreaseIncrementTimer

var amount: int = 0:
	set(value):
		amount = value

		amount_changed.emit(amount)

		if amount > max_amount:
			amount = max_amount

		if value > 0:
			if not %AmountPanelContainer.visible:
				%AmountPanelContainer.visible = true
			if %RemoveAllButton.disabled:
				%RemoveAllButton.disabled = false
			%AmountLabel.text = str(amount)
		else:
			%AmountPanelContainer.visible = false
			%RemoveAllButton.disabled = true
			%AmountLabel.text = str(amount)

@export var _item_name: String = "":
	set(value):
		_item_name = value
		if _item_name.is_empty():
			%ItemButton.text = PLACEHOLDER_BUTTON_TEXT
			return
		
		%ItemButton.text = _item_name

@export var max_amount: int = 999

var _increment: int = 1

var _is_subtraction_held: int = -1
var _is_addition_held: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_handle_holding()

func _on_item_button_button_down() -> void:
	var old = amount
	amount += 1
	amount_increased.emit(old, amount)

	_is_addition_held = 0
	_hold_timer.timeout.connect(_on_hold_timer_timeout)
	_hold_timer.start()
func _on_item_button_button_up() -> void:
	if not _hold_timer.is_stopped():
		_hold_timer.stop()
	if not _increase_increment_timer.is_stopped():
		_increase_increment_timer.stop()
	if _hold_timer.timeout.is_connected(_on_hold_timer_timeout):
		_hold_timer.timeout.disconnect(_on_hold_timer_timeout)
	if _increase_increment_timer.timeout.is_connected(_on_increase_increment_timer_timeout):
		_increase_increment_timer.timeout.disconnect(_on_increase_increment_timer_timeout)
	_is_addition_held = -1
	_increment = 1

func _on_remove_all_button_pressed() -> void:
	var old = amount
	amount = 0
	amount_cleared.emit(old)
	_increment = 1

func _on_subtract_button_button_down() -> void:
	var old = amount
	amount -= 1
	amount_decreased.emit(old, amount)
	if amount == 0:
		return

	_is_subtraction_held = 0
	_hold_timer.timeout.connect(_on_hold_timer_timeout)
	_hold_timer.start()
func _on_subtract_button_button_up() -> void:
	if not _hold_timer.is_stopped():
		_hold_timer.stop()
	if not _increase_increment_timer.is_stopped():
		_increase_increment_timer.stop()
	if _hold_timer.timeout.is_connected(_on_hold_timer_timeout):
		_hold_timer.timeout.disconnect(_on_hold_timer_timeout)
	if _increase_increment_timer.timeout.is_connected(_on_increase_increment_timer_timeout):
		_increase_increment_timer.timeout.disconnect(_on_increase_increment_timer_timeout)
	_is_subtraction_held = -1
	_increment = 1

func _on_add_button_button_down() -> void:
	var old = amount
	amount += 1
	amount_increased.emit(old, amount)
	if amount == max_amount:
		return

	_is_addition_held = 0
	_hold_timer.timeout.connect(_on_hold_timer_timeout)
	_hold_timer.start()
func _on_add_button_button_up() -> void:
	if not _hold_timer.is_stopped():
		_hold_timer.stop()
	if not _increase_increment_timer.is_stopped():
		_increase_increment_timer.stop()
	if _hold_timer.timeout.is_connected(_on_hold_timer_timeout):
		_hold_timer.timeout.disconnect(_on_hold_timer_timeout)
	if _increase_increment_timer.timeout.is_connected(_on_increase_increment_timer_timeout):
		_increase_increment_timer.timeout.disconnect(_on_increase_increment_timer_timeout)
	_is_addition_held = -1
	_increment = 1


func _handle_holding():
	if (_is_subtraction_held == -1) and (_is_addition_held == -1):
		return

	if _is_addition_held == 1:
		var old = amount
		amount += _increment
		amount_increased.emit(old, amount)
	elif _is_subtraction_held == 1:
		var old = amount
		amount -= _increment
		amount_decreased.emit(old, amount)

func _on_hold_timer_timeout() -> void:
	_hold_timer.timeout.disconnect(_on_hold_timer_timeout)
	if _is_addition_held == 0:
		_is_addition_held = 1
	elif _is_subtraction_held == 0:
		_is_subtraction_held = 1
	
	_increase_increment_timer.timeout.connect(_on_increase_increment_timer_timeout)
	_increase_increment_timer.start()

func _on_increase_increment_timer_timeout():
	if _increase_increment_timer.timeout.is_connected(_on_increase_increment_timer_timeout):
		_increase_increment_timer.timeout.disconnect(_on_increase_increment_timer_timeout)
	_increment = INCREASED_INCREMENT
