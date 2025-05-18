class_name PlayableCharacterStaminaMeter
extends Node3D

var _source_status: CharacterStatus

@onready var _texture_progress_bar: TextureProgressBar = %TextureProgressBar

var _max_value: int:
	set(value):
		_max_value = value
		if _value > _max_value:
			_value = _max_value
		_texture_progress_bar.max_value = _max_value
var _value: int:
	set(value):
		_value = value
		if _value > _max_value:
			_value = _max_value
		_texture_progress_bar.value = _value

func initialize(status: CharacterStatus) -> void:
	_source_status = status
	
	_source_status.max_stamina_modified.connect(_on_source_status_max_stamina_modified)
	_source_status.stamina_modified.connect(_on_source_status_stamina_modified)
	
	_max_value = _source_status.get_max_stamina()
	_value = _source_status.get_stamina()

func _on_source_status_max_stamina_modified(old: int, new: int):
	_max_value = new
func _on_source_status_stamina_modified(old: int, new: int):
	_value = new
