class_name Party
extends Resource

## the party reasource is reponsible for defining a list of three characters (by PackedScene).

var deployed_party: Dictionary[StringName, Character]
var deployed_party_container: PlayableCharacterCharacterContainer

@export var _max_members: int = 3

@export var member_internal_names: Array[StringName]
@export var preset_title: String

## should not be called directly. PlayableCharacterPartyManager should be the only
## user of this method.
func deploy(character_container: PlayableCharacterCharacterContainer):
	deployed_party_container = character_container
	deployed_party_container.clear_characters()
	deployed_party = {}

	for internal_name in member_internal_names:
		if internal_name.is_empty():
			continue
		var character_packet = Characters.get_character_packet(internal_name)
		add_member_packedscene(character_packet.character_scene)
	
	deployed_party_container.handle_switch_to_character(0)

func withdraw():
	for member_internal_name in deployed_party.keys():
		remove_member(member_internal_name)
	
	deployed_party_container.clear_characters()
	deployed_party_container = null
	deployed_party = {}

func add_member_packedscene(packedscene: PackedScene):
	assert(deployed_party.size() + 1 <= _max_members, "Maximum allowed members exceeded in Party {party}.".format({
		"party" : self.to_string()
	}))
	
	var character: Character = packedscene.instantiate()
	var internal_name = character.get_character_data().internal_name
	
	assert(not deployed_party.has(internal_name), "Character {internal_name} is already a member of Party {party}.".format({
		"internal_name" : internal_name,
		"party" : self.to_string()
	}))
	
	character.initialize()
	deployed_party[internal_name] = character
	deployed_party_container.add_character(character)

func remove_member(character_internal_name: StringName):
	assert(deployed_party.has(character_internal_name), "No Member found by {internal_name} in Party {party}.".format({
		"internal_name" : character_internal_name,
		"party" : self.to_string()
	}))
	
	var character = deployed_party[character_internal_name]
	deployed_party.erase(character_internal_name)
	deployed_party_container.remove_character(character)

func is_full() -> bool:
	return not member_internal_names.has("")

func is_empty() -> bool:
	return member_internal_names.all(func(name): return name == "")
