class_name PlayableCharacterCharacterStage
extends Node3D

@onready var character_stage_nonplayable_character: NonplayableCharacter = %CharacterStageNonplayableCharacter

var current_character_internal_name: StringName:
	set(value):
		current_character_internal_name = value
		
		var nonplayable_character_character_container = character_stage_nonplayable_character.nonplayable_character_character_container
		
		nonplayable_character_character_container.clear_characters()
		
		if current_character_internal_name.is_empty():
			return
		
		# set current inspected character to current active character
		var character_packet = Characters.get_character_packet(current_character_internal_name)
		nonplayable_character_character_container.add_character_packet(character_packet)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
