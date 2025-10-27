@tool
class_name CharacterAttackState
extends FSMState

enum AttackType
{
	TYPE_NO_ATTACK,
	TYPE_LIGHT_ATTACK,
	TYPE_CHARGED_LIGHT_ATTACK,
	TYPE_HEAVY_ATTACK,
	TYPE_CHARGED_HEAVY_ATTACK
}

const ANIMATION_NAMES: Dictionary[AttackType, String] = {
	AttackType.TYPE_NO_ATTACK				: "",
	AttackType.TYPE_LIGHT_ATTACK			: "light_attack",
	AttackType.TYPE_CHARGED_LIGHT_ATTACK	: "charged_light_attack",
	AttackType.TYPE_HEAVY_ATTACK			: "heavy_attack",
	AttackType.TYPE_CHARGED_HEAVY_ATTACK	: "charged_heavy_attack"
}

@export var attack_type: AttackType = AttackType.TYPE_NO_ATTACK:
	set(value):
			attack_type = value
			if not Engine.is_editor_hint():
				return
			
			animation_name = ANIMATION_NAMES[attack_type]
@export var animation_name: String:
	set(value):
		animation_name = value
		if not Engine.is_editor_hint():
			return
		
		# if the animation_name field is empty fill it with a placeholder name.
		if animation_name.is_empty():
			animation_name = ANIMATION_NAMES[attack_type]

# Executes after the state is entered.
func _on_enter(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# func get_animation_name() -> String:
# 	return ANIMATION_NAMES[attack_type]
