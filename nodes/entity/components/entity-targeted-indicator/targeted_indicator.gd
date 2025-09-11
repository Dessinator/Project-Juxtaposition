class_name TargetedIndicator
extends Node3D

@onready var _sprite_3d: Sprite3D = %Sprite3D

func _ready() -> void:
	_sprite_3d.frame = 0

func _on_trackable_target_tracked() -> void:
	_sprite_3d.frame = 1

func _on_trackable_target_untracked() -> void:
	_sprite_3d.frame = 0

func _on_trackable_target_entered_target_range() -> void:
	visible = true

func _on_trackable_target_exited_target_range() -> void:
	visible = false
