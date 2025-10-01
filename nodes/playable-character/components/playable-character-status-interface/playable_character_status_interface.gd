extends StatusInterface
class_name PlayableCharacterStatusInterface

func initialize(status: CharacterStatus) -> void:
	_set_current_status(status)

func _on_playable_character_character_container_current_character_changed(old: Character, new: Character) -> void:
	_set_current_status(new.get_character_status())

func _set_current_status(status: CharacterStatus):
	_status = status
