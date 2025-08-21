@tool
class_name CharacterComboChainHeavyAttackGraphNode
extends CharacterComboChainGraphNode

func _create_attack_node() -> CharacterComboChainAttackNode:
	return CharacterComboChainHeavyAttackNode.new()
