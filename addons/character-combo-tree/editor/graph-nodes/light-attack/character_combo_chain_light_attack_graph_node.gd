@tool
class_name CharacterComboChainLightAttackGraphNode
extends CharacterComboChainGraphNode

func _create_attack_node() -> CharacterComboChainAttackNode:
	return CharacterComboChainLightAttackNode.new()
