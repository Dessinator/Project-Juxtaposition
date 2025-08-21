@tool
class_name CharacterComboChainGraphNode
extends GraphNode

# either CharacterComboChainRootNode or CharacterComboChainAttackNode
var node

# override this with a function to create the CharacterComboChainAttackNode
# associated with the inherited CharacterComboChainGraphNode 
func _create_attack_node() -> CharacterComboChainAttackNode:
	return null
