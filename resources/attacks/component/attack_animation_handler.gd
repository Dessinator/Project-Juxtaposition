class_name AttackAnimationHandler
extends AttackComponent

@export var _animation_name: StringName

func _do(playable_character: PlayableCharacter, attack_definition: AttackDefinition, attack_instance: AttackInstance) -> void:
	var character = playable_character.get_character()
	
	var animation_names = character.get_character_model_animation_names()
	
	assert(animation_names.has(_animation_name), "Character '{character_name}' does not have an animation named '{animation_name}'.".format({
		"character_name" : character.name,
		"animation_name" : _animation_name
	}))
	
	var animation_player = character.get_character_model_animation_player()
	
	animation_player.play(_animation_name)
	animation_player.animation_finished.connect(_on_animation_player_finished.bind(
		playable_character,
		attack_definition,
		attack_instance
	))

func _on_animation_player_finished(animation_name: String, playable_character: PlayableCharacter, attack_definition: AttackDefinition, attack_instance: AttackInstance):
	if not animation_name == _animation_name:
		return
	
	_handle_end(attack_definition)

func _handle_end(attack_definition: AttackDefinition):
	attack_definition.end()
