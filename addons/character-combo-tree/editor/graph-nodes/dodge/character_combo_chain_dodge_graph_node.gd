@tool
class_name CharacterComboChainDodgeGraphNode
extends CharacterComboChainGraphNode

func _create_attack_node() -> CharacterComboChainAttackNode:
	return CharacterComboChainDodgeNode.new()
