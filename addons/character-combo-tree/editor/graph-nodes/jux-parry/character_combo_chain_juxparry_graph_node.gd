@tool
class_name CharacterComboChainJuxparryGraphNode
extends CharacterComboChainGraphNode

func _create_attack_node() -> CharacterComboChainAttackNode:
	return CharacterComboChainJuxParryNode.new()
