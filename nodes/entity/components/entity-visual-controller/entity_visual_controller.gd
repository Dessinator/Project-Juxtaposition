class_name EntityVisualController
extends Node

@export var _health_bar: EntityFloatingHealthBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_health_bar_visible(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_health_bar_visible(value: bool):
	_health_bar.visible = value

func _on_trackable_target_entered_target_range() -> void:
	_set_health_bar_visible(true)

func _on_trackable_target_exited_target_range() -> void:
	_set_health_bar_visible(false)
