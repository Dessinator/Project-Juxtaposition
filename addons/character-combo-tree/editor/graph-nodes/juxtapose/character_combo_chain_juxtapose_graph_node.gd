@tool
class_name CharacterComboChainJuxtaposeGraphNode
extends CharacterComboChainGraphNode

func _create_attack_node() -> CharacterComboChainAttackNode:
	return CharacterComboChainJuxtaposeNode.new()
