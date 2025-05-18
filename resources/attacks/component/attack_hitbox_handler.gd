class_name AttackHitboxHandler
extends AttackComponent

@export var _hitbox_animation_name: StringName

func _do(playable_character: PlayableCharacter, attack_definition: AttackDefinition, attack_instance: AttackInstance) -> void:
	var character = playable_character.get_character()
	
	var hitbox_animation_names = character.get_character_model_hitbox_animation_names()
	
	assert(hitbox_animation_names.has(_hitbox_animation_name), "Character '{character_name}' does not have a hitbox animation named '{hitbox_animation_name}'.".format({
		"character_name" : character.name,
		"hitbox_animation_name" : _hitbox_animation_name
	}))
	
	var hitbox_animation_player = character.get_character_model_hitbox_animation_player()
	
	hitbox_animation_player.play(_hitbox_animation_name)
