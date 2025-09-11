class_name TrackableTarget
extends Node3D

signal entered_target_range
signal exited_target_range
signal tracked
signal untracked

var _is_in_range: bool:
	set(value):
		_is_in_range = value
		
		if _is_in_range:
			entered_target_range.emit()
			return
		exited_target_range.emit()
var _tracked: bool:
	set(value):
		_tracked = value
		
		if _tracked:
			tracked.emit()
			return
		untracked.emit()

func set_is_in_range(value: bool):
	_is_in_range = value
func set_tracked(value: bool):
	_tracked = value
