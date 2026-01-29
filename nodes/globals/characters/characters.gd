extends Node

## a global responsible for providing access to character data and their
## associated scene.

const CHARACTERS_PATH = "res://nodes/character/prefabs"

var _characters: Dictionary[StringName, CharacterPacket]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_characters = {}
	_create_character_packets_from_characters_path()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_character_packet(internal_name: StringName) -> CharacterPacket:
	assert(_characters.has(internal_name), "Characters: No CharacterPacket found by name '{internal_name}'".format({
		"internal_name" : internal_name
	}))

	var character_packet = _characters[internal_name]
	return character_packet
func get_all_character_packets() -> Array[CharacterPacket]:
	return _characters.values() as Array[CharacterPacket]

func _create_character_packets_from_characters_path():
	var character_resource_paths = ResourceLoader.list_directory(CHARACTERS_PATH)

	for path in character_resource_paths:
		var full_path = CHARACTERS_PATH +"/"+ path
		print("Loading Character .tscn file '{full_path}'...".format({ "full_path" : full_path }))

		var character_scene: PackedScene = ResourceLoader.load(full_path, "PackedScene") as PackedScene
		if not character_scene:
			print("No Character Scene Found!")
			continue
		
		print("Sucessfully loaded Character .tscn file '{full_path}'!".format({ "full_path" : full_path }))

		print("Looking for CharacterData resource...")
		var character_internal_name: StringName
		var character_data: CharacterData
		var scene_state = character_scene.get_state()
		for i in range(scene_state.get_node_property_count(0)):
			var temp_character_data = scene_state.get_node_property_value(0, i)
			if not temp_character_data is CharacterData:
				continue
			
			character_data = temp_character_data as CharacterData
			character_internal_name = character_data.internal_name

			print("Found CharacterData!")
			print("full_name: " + character_data.full_name)
			print("internal_name: " + character_data.internal_name)
			break
		
		if not character_data:
			print("No Character Data Found!")
			continue
		
		var character_packet: CharacterPacket = CharacterPacket.new()
		character_packet.character_data = character_data
		character_packet.character_scene = character_scene

		_characters[character_internal_name] = character_packet

		print("Created new CharacterPacket stored by name '{internal_name}'!".format({ "internal_name" : character_internal_name}))
