class_name PlayableCharacterStaminaMeter
extends Node3D

var _source_status: CharacterStatus

@onready var _texture_progress_bar: TextureProgressBar = %TextureProgressBar
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _fade_out_timer: Timer = %FadeOutTimer

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
var _hidden: bool = true

var _world_origin: Marker3D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func set_character_status(status: CharacterStatus) -> void:
	_source_status = status
	
	_source_status.max_stamina_modified.connect(_on_source_status_max_stamina_modified)
	_source_status.stamina_modified.connect(_on_source_status_stamina_modified)
	
	_max_value = _source_status.get_max_stamina()
	_value = _source_status.get_stamina()

func _on_source_status_max_stamina_modified(old: int, new: int):
	_max_value = new
	if _hidden:
		_fade_in()
	_fade_out_timer.start()
func _on_source_status_stamina_modified(old: int, new: int):
	_value = new
	if _hidden:
		_fade_in()
	_fade_out_timer.start()

func _on_fade_out_timer_timeout():
	_fade_out()

func _fade_in():
	_hidden = false
	_animation_player.play("fade_in")
func _fade_out():
	_hidden = true
	_animation_player.play("fade_out")
