class_name CinematicBars
extends Control

@onready var _top_bar: Control = %TopBar
@onready var _bottom_bar: Control = %BottomBar

var _active: bool = false

@export var max_drama: int

func activate():
	var tween = create_tween()
	tween.tween_property(_top_bar, "position:y", max_drama, 0.2)
	tween.parallel().tween_property(_bottom_bar, "position:y", -max_drama, 0.2)

func deactivate():
	var tween = create_tween()
	tween.tween_property(_top_bar, "position:y", 0, 0.5)
	tween.parallel().tween_property(_bottom_bar, "position:y", 0, 0.5)
