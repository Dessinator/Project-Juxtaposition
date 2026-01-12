class_name PlayableCharacterPartyManager
extends Node

@onready var _playable_character_character_container: PlayableCharacterCharacterContainer = %PlayableCharacterCharacterContainer

var playable_character: PlayableCharacter

@export var current_party: Party
@export var party_presets: Dictionary[String, Party]

func initialize(playable_character: PlayableCharacter):
	self.playable_character = playable_character

	deploy_party(current_party)

func deploy_party(party: Party):
	current_party = party

	current_party.deploy(_playable_character_character_container) 
