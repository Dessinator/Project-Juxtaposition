class_name ActionTypeAvailabilityModifier
extends Resource

# workaround for no nested typed collections

@export var action_type: PlayableCharacterGameplayState.PlayableCharacterActionType = PlayableCharacterGameplayState.PlayableCharacterActionType.TYPE_OTHER

@export var set_action_available: bool = false
@export var set_action_unavailable: bool = false
@export var set_action_available_duration: float = 0
@export var set_action_unavailable_duration: float = 0
