@tool
extends FSMState

@export var _character: Character
@export var _animation_name: StringName

func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	var animation_player = _character.get_character_model_animation_player()
	
	animation_player.play(_animation_name)
