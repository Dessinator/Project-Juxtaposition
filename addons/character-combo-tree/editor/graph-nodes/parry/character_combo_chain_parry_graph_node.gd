@tool
class_name CharacterComboChainParryGraphNode
extends CharacterComboChainGraphNode

func _create_attack_node() -> CharacterComboChainAttackNode:
	return CharacterComboChainParryNode
