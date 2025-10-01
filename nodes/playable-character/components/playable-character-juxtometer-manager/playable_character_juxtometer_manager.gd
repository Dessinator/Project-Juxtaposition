extends Node
class_name PlayableCharacterJuxtometerManager

var _playable_character: PlayableCharacter

func initialize(playable_character: PlayableCharacter) -> void:
	_playable_character = playable_character

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_playable_character_character_container_current_character_changed(old: Character, new: Character) -> void:
	if old:
		var old_character_status = old.get_character_status()
		old_character_status.damaged.disconnect(_on_current_character_damage_taken)
	var new_character_status = new.get_character_status()
	new_character_status.damaged.connect(_on_current_character_damage_taken)

func _on_playable_character_combat_manager_damage_dealt(damage: int) -> void:
	var character_container = _playable_character.get_playable_character_character_container()
	var current_character = character_container.get_current_character()
	var status = current_character.get_character_status()
	var stats = current_character.get_character_stats()
	
	var juxtometer_addition = stats.sample_juxtometer_damage_dealt_curve(damage)
	status.fill_juxtometer(juxtometer_addition)
func _on_current_character_damage_taken(damage_instance: DamageInstance):
	var character_container = _playable_character.get_playable_character_character_container()
	var current_character = character_container.get_current_character()
	var status = current_character.get_character_status()
	var stats = current_character.get_character_stats()
	
	var juxtometer_addition = stats.sample_juxtometer_damage_dealt_curve(damage_instance.base_damage)
	status.deplete_juxtometer(juxtometer_addition)
