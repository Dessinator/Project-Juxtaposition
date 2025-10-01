@tool
extends PlayableCharacterGameplayState

@onready var _character_replace_immunity_timer: Timer = %CharacterReplaceImmunityTimer

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	super(actor, blackboard)
	actor = actor as PlayableCharacter
	
	var character_container = actor.get_playable_character_character_container()
	var character = character_container.get_current_character()
	
	var next_character_index = character_container.get_next_alive_character_index()
	character_container.handle_switch_to_character(next_character_index)
	
	var replacement_character = character_container.get_current_character()
	var replacement_character_status = replacement_character.get_character_status()
	replacement_character_status.set_immune(true)
	
	_character_replace_immunity_timer.start()


# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
