@tool
class_name CharacterComboChainJuxdodgeGraphNode
extends CharacterComboChainGraphNode

func _create_attack_node() -> CharacterComboChainAttackNode:
	return CharacterComboChainJuxDodgeNode.new()
