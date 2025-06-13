@tool
extends FSMState

@export var _camera: PlayableCharacterCamera
@export var _character: Character

@export var _gravity: float

func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as PlayableCharacter

func _on_update(delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	pass
