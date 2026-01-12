class_name Party
extends Resource

## the party reasource is reponsible for defining a list of three characters (by PackedScene).

var deployed_party: Array[Character]

@export var member_packedscenes: Array[PackedScene]
@export var preset_title: String

func deploy(character_container: PlayableCharacterCharacterContainer):
    character_container.clear_characters()
    deployed_party = []

    for packedscene in member_packedscenes:
        var character = packedscene.instantiate()
        character_container.add_character(character)
        deployed_party.append(character)
    
    character_container.handle_switch_to_character(0)
        